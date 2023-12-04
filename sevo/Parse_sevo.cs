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
