using Godot;
using MessagePack;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading;

public partial class Parse_sevo : Node
{
	public byte[] byte_matrix;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public MessagePackSerializerOptions lz4Options = MessagePackSerializerOptions.Standard.WithCompression(MessagePackCompression.Lz4Block);

	[MessagePackObject(false)]
	public struct InputTextData
	{
	  [Key(0)]
	  public string text { get; set; }

	  [Key(1)]
	  public bool isWrapped { get; set; }

	  [Key(2)]
	  public int font { get; set; }

	  [Key(3)]
	  public float fontSize { get; set; }
	}

	public void PrintMP(string path) {
		//var lz4Options = MessagePackSerializerOptions.Standard.WithCompression(MessagePackCompression.Lz4Block);
		Sevo.BrickEntityMp pri = MessagePackSerializer.Deserialize<Sevo.BrickEntityMp>(Godot.FileAccess.GetFileAsBytes(path),lz4Options);
		var cd = pri.Commands[1];//.customData;
		//var rd = MessagePackSerializer.Deserialize<InputTextData>(cd);
		
		GD.Print(JsonSerializer.Serialize(cd));
	}

	public void WriteMP(string[] matrix,string mName = "new",long mfont = 0, double mfont_size = 7.2) {
		string path = "res://Matrix_16S_Template/Matrix_16S_Template.sevo";
		
		Sevo.BrickEntityMp mp = MessagePackSerializer.Deserialize<Sevo.BrickEntityMp>(Godot.FileAccess.GetFileAsBytes(path),lz4Options);
		mp.EntityName = mName;
		for (int i = 0; i < matrix.Count(); i++) {
			// Set each screen in template to i
			var ds = mp.Commands[i].customData;
			if (ds == null){continue;}

			var itd = MessagePackSerializer.Deserialize<InputTextData>(ds);
			if (mfont > 1) {
				GD.PrintErr("Assigned Non-existant font, corruption likely.");
			}
			
			itd.text = matrix[i].ToString();
			if (matrix[i].ToString() != (string)GetNode<Node>("/root/Gsb").Get("delete_screen")) {
				itd.font = (int)mfont;
				itd.fontSize = (float)mfont_size;
			}
			else {
				itd.font = 0;
				itd.fontSize = (float)7.2;
			}
			mp.Commands[i].customData = MessagePackSerializer.Serialize<InputTextData>(itd, (MessagePackSerializerOptions) null, new CancellationToken());
		}
		byte_matrix = MessagePackSerializer.Serialize<Sevo.BrickEntityMp>(mp,lz4Options);
	}

	public void BreakMP(string path) {
		Sevo.BrickEntityMp mp = MessagePackSerializer.Deserialize<Sevo.BrickEntityMp>(Godot.FileAccess.GetFileAsBytes(path),lz4Options);
		for (int i = 0; i < mp.Commands.Count; i++) {
			var ds = mp.Commands[i].customData;
			if (ds == null){continue;}

			var itd = MessagePackSerializer.Deserialize<InputTextData>(ds);
			//GD.Print("editing screen ",i," ",JsonSerializer.Serialize(itd));
			//if (itd.text == "hi") {GD.Print("Found hi");}
			itd.text = i.ToString();
			//GD.Print("finsihed editting ",i," ",JsonSerializer.Serialize(itd));
			mp.Commands[i].customData = MessagePackSerializer.Serialize<InputTextData>(itd, (MessagePackSerializerOptions) null, new CancellationToken());
		}
		byte[] new_mp = MessagePackSerializer.Serialize<Sevo.BrickEntityMp>(mp,lz4Options);
		SaveToDiskAtPath(path,new_mp);
		GD.Print("end");
	}

	public void CreateMP(string[] matrix,long subdiv = 16,string mName = "new",long mfont = 0, double mfont_size = 7.2) {
		string path = "res://Matrix_16S_Template/Matrix_16S_Template.sevo";

		Sevo.BrickEntityMp NEW = MessagePackSerializer.Deserialize<Sevo.BrickEntityMp>(Godot.FileAccess.GetFileAsBytes(path),lz4Options);//new Sevo.BrickEntityMp();
		Sevo.BrickEntityMp REF = MessagePackSerializer.Deserialize<Sevo.BrickEntityMp>(Godot.FileAccess.GetFileAsBytes(path),lz4Options);

		NEW.EntityName = mName;
		//NEW.BrickDatas.Datas = new Sevo.BrickInstanceData();
		Sevo.BrickDatasSave newbds = new Sevo.BrickDatasSave();
		newbds.Datas = new Sevo.BrickInstanceData[matrix.Length + 1];
        NEW.BrickDatas = newbds;
        NEW.Commands = new List<Sevo.NewCommand_mp>(new Sevo.NewCommand_mp[matrix.Length]);

		//screens can't have IDs of 0 I think
		NEW.BrickDatas.Datas[0] = REF.BrickDatas.Datas[0];

		int row = 0;
		int rowidx = 0;
		int column = 0;

		if (mfont > 1 ^ mfont < 0) {
				GD.PrintErr("Assigned Non-existant font, corruption likely.");
			}

		for (int i = 0; i < matrix.Length; i++) {
			// Sevo.NewCommand_mp screen = REF.Commands[9];
			Sevo.NewCommand_mp screen = new Sevo.NewCommand_mp(
				REF.Commands[9].commandTargets,
				REF.Commands[9].data,
				REF.Commands[9].state,
				REF.Commands[9].customData,
				REF.Commands[9].childrenBrickId,
				REF.Commands[9].commandLabel
			);
			InputTextData screendata = new InputTextData();
			Sevo.ChildrenBrickId newbid = new Sevo.ChildrenBrickId();
			screendata.text = matrix[i].ToString();
			screendata.isWrapped = false;
			screendata.font = (int)mfont;
			screendata.fontSize = (float)mfont_size;

			newbid.brickId = i + 1;
			newbid.childrenId = -1; //this is just how it is...
			// Why 9, I'm pretty sure it's a screen.
			screen.childrenBrickId = newbid;
			byte[] cds = MessagePackSerializer.Serialize<InputTextData>(screendata, (MessagePackSerializerOptions) null, new CancellationToken());
			screen.customData = cds;
			
			Sevo.BrickInstanceData screeninstancedata = new Sevo.BrickInstanceData();
			UnityEngine.Vector3Int gpos = new UnityEngine.Vector3Int();
			screeninstancedata = REF.BrickDatas.Datas[9];
			gpos.x = 0;
			gpos.y = row;
			gpos.z = column;
			screeninstancedata.gridPosition = gpos;
			screeninstancedata.instanceId = i + 1;
			//// NEW.Commands.Append(screen);
			// GD.Print(matrix.Length," - ",NEW.Commands.Count," - ",i);
			NEW.Commands[i] = screen;
			//NEW.BrickDatas.Datas.SetValue(screeninstancedata,i);
			NEW.BrickDatas.Datas[i + 1] = screeninstancedata;

			column += 8;
			if (rowidx == subdiv - 1) {
				rowidx = 0;
				column = 0;
				row -= 8;
			} else {
				rowidx += 1;
			};
		}

		byte_matrix = MessagePackSerializer.Serialize<Sevo.BrickEntityMp>(NEW,lz4Options);
	}

	public void ReadMP(string path) {
		Sevo.BrickEntityMp mp = MessagePackSerializer.Deserialize<Sevo.BrickEntityMp>(Godot.FileAccess.GetFileAsBytes(path),lz4Options);
		//GD.Print(mp.Commands.First().childrenBrickId.brickId);
		//GD.Print(mp.BrickDatas.Datas.First().instanceId);
		//GD.Print(mp.Commands[9]);
		//GD.Print(mp.BrickDatas.IdsToRecycle);
		//GD.Print(mp.BrickDatas.Datas.Count());
		//var itd = MessagePackSerializer.Deserialize<InputTextData>(mp.Commands.Last().customData);
		//GD.Print(itd.text);
		var i = 0;
		foreach (Sevo.BrickInstanceData bds in mp.BrickDatas.Datas) {
			GD.Print(bds.instanceId);
			GD.Print(mp.Commands[i].childrenBrickId.brickId);
			i++;
		}
		//foreach (Sevo.NewCommand_mp nc in mp.Commands) {
			//var itd = MessagePackSerializer.Deserialize<InputTextData>(nc.customData);
			//GD.Print(itd.text);
			//GD.Print(nc.commandLabel);
			//GD.Print(nc.childrenBrickId.brickId);
		//}
	}

	public Godot.Vector3 Unity2GodotV3(UnityEngine.Vector3 u2g) {
		Godot.Vector3 newu2g = Vector3.Zero;
		newu2g.X = u2g.x;
		newu2g.Y = u2g.y;
		newu2g.Z = u2g.z;
		return newu2g;
	}

	public Godot.Vector3I Unity2GodotV3I(UnityEngine.Vector3Int u2g) {
		Godot.Vector3I newu2g = Vector3I.Zero;
		newu2g.X = u2g.x;
		newu2g.Y = u2g.y;
		newu2g.Z = u2g.z;
		return newu2g;
	}

	public void SaveToDiskAtPath(string path,byte[] data) {
		if (Godot.FileAccess.FileExists(path)) {
			if (new FileInfo(path).Length > 1L) {
				File.Copy(path, path + "bu",true);
			}
		}
		using (FileStream fileStream = File.Create(path)) {
			fileStream.Write(data,0,data.Length);
		}
	}
}
