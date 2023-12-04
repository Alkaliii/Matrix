using Godot;
using MessagePack;
using System;
using System.Collections.Generic;
using System.Windows;
using UnityEngine;

public partial class Sevo : Node
{
	[MessagePackObject(false)]
	public class BrickEntityMp
	{
	
		[Key(0)]
		public string Sguid { get; set; }

		[Key(1)]
		public string EntityName { get; set; }

		[Key(2)]
		public object ShipyardRespawnPoint { get; set; }

		[Key(3)]
		public Dictionary<int, Dictionary<int, object>> LegacyCommands { get; set; }

		[Key(4)]
		public int EntityType { get; set; }

		[Key(5)]
		public ulong SteamFileId { get; set; }
		[Key(6)]
		public object InventoryMp { get; set; }

		[Key(7)]
		public List<BrickDatasSave> BrickDatasChildrens { get; set; }

	
		[Key(8)]
		public BrickDatasSave BrickDatas { get; set; }


		[Key(9)]
		public List<NewCommand_mp> Commands { get; set; }


		[Key(10)]
		public object ClipboardData { get; set; }
		
		[Key(11)]
		public int Version { get; set; }

		[Key(12)]
		public object BrickTagDatas { get; set; }

		public void ClearInstanceData()
		{
			this.Sguid = null;
		}
	}

	[MessagePackObject(false)]
  	public struct ChildrenBrickId
  	{
    [Key(0)]
    public int childrenId;
    [Key(1)]
    public int brickId;
  	}

	[MessagePackObject(false)]
  	public class NewCommand_mp
  	{
    public const int INVALID_COMMAND = -2;

    [Key(4)]
    public ChildrenBrickId childrenBrickId { get; set; }

    [Key(0)]
    public ChildrenBrickId[] commandTargets { get; set; }

    [Key(1)]
    public int data { get; set; }

    [Key(2)]
    public float state { get; set; }

    [Key(3)]
    public byte[] customData { get; set; }

    [Key(5)]
    public string commandLabel { get; set; }

    [SerializationConstructor]
    public NewCommand_mp(
      ChildrenBrickId[] commandTargets,
      int data,
      float state,
      byte[] customData,
      ChildrenBrickId childrenBrickId,
      string commandLabel)
    {
      this.data = data;
      this.state = state;
      this.customData = customData;
      this.commandTargets = commandTargets;
      this.childrenBrickId = childrenBrickId;
      this.commandLabel = commandLabel;
    }
	}
	//public class CommandInputText : 

	[MessagePackObject(false)]
    public struct BrickDatasSave
    {
        [IgnoreMember]
        public int Length
        {
            get
            {
                BrickInstanceData[] array = this.Datas;
                if (array == null)
                {
                    return 0;
                }

                return array.Length;
            }
        }

        [Key(0)] public BrickInstanceData[] Datas;


        [Key(1)] public int[] IdsToRecycle;

        [Key(2)] public Dictionary<int, byte[]> AdditionalDatas;
    }

	[MessagePackObject(false)]
    public struct BrickInstanceData
    {
        [IgnoreMember]
        public Brick brick => Brick.BRICK_INDEX[(int)this.brickId];

        [IgnoreMember]
        public float healthFactor => (float)this.healthScore / 255f;

        [IgnoreMember]
        public int Material => (int)this.material;

        [IgnoreMember]
        public UnityEngine.Vector3 Position => new UnityEngine.Vector3((float)this.gridPosition.x / 32f, (float)this.gridPosition.y / 32f, (float)this.gridPosition.z / 32f);

        [IgnoreMember]
        public Vector3Int Scale => new Vector3Int((int)(this.scale & 15), this.scale >> 4 & 15, this.scale >> 8 & 15);

        [IgnoreMember]
        public UnityEngine.Vector3 scaleFloat => new UnityEngine.Vector3((float)(this.scale & 15), (float)(this.scale >> 4 & 15), (float)(this.scale >> 8 & 15));

        //[IgnoreMember]
        //public UnityEngine.Vector3 scaleFloatCollision => new UnityEngine.Vector3(this.brick.CollisionScaleFactor,this.brick.CollisionScaleFactor,this.brick.CollisionScaleFactor) * this.scaleFloat;

        [IgnoreMember]
        public int Quaternion => (int)this.rotation;

        [IgnoreMember]
        public int quaternionInv => (int)this.rotation;

        [IgnoreMember]
        public bool IsMaxHealth => this.healthScore == byte.MaxValue;

        [IgnoreMember]
        public bool IsValid => this.instanceId != 0 && this.brickId > 0;

        [IgnoreMember]
        public float GridSize => (float)Math.Pow(2f, (float)this.gridSize) * 0.125f;

        //return GetGridSize(this.brick, (int)this.gridSize);
        [IgnoreMember]
        public int GridSizeUnit =>
            //return BrickCommon.GetGridSizeUnit((int)this.gridSize);
            (int)(4f * Math.Pow(2f, (float)this.gridSize));

        [IgnoreMember]
        public int UnitGrid => 0;

        //return (int)Math.Round(this.GridSize * (float)this.brick.VoxelMesh.ResizeMode.unitStud);
        [IgnoreMember]
        public int MaximumHealthPoint => 255;

        [IgnoreMember]
        public int CurrentHealthPoint => (int)Math.Ceiling(this.healthFactor * (float)this.MaximumHealthPoint);

        public float GetGridSize(bool isDynamicGridSize)
        {
            if (!isDynamicGridSize)
            {
                return 1f;
            }
            return (float)Math.Pow(2f, (float)this.gridSize) * 0.125f;
        }

        public override bool Equals(object other)
        {
            if (!(other is BrickInstanceData))
            {
                return false;
            }
            BrickInstanceData brickInstanceData = (BrickInstanceData)other;
            return this.instanceId == brickInstanceData.instanceId;
        }

        public bool Equals(BrickInstanceData other)
        {
            return this.instanceId == other.instanceId;
        }

        public override int GetHashCode()
        {
            return base.GetHashCode();
        }

        public static float GetGridSize(Brick brick, int grid)
        {
            if (!brick.isDynamicGridSize)
            {
                return 1f;
            }
            return (float)Math.Pow(2f, (float)grid) * 0.125f;
        }

        public static bool operator ==(BrickInstanceData a, BrickInstanceData b)
        {
            return a.gridPosition.Equals(b.gridPosition) & a.brickId == b.brickId & a.rotation == b.rotation & a.scale == b.scale;
        }

        public static bool operator !=(BrickInstanceData a, BrickInstanceData b)
        {
            return !a.gridPosition.Equals(b.gridPosition) | a.brickId != b.brickId | a.rotation != b.rotation | a.scale != b.scale;
        }

        public const byte MAX_HEALTH = 255;

        [Key(0)]
        public ushort brickId;

        [Key(1)]
        public Vector3Int gridPosition;

        [Key(2)]
        public ushort scale;

        [Key(3)]
        public byte rotation;

        [Key(4)]
        public object color;

        [Key(5)]
        public uint material;

        [Key(6)]
        public byte healthScore;

        [Key(7)]
        public int instanceId;

        [Key(8)]
        public byte gridSize;
    }

	public class Brick
	{
		// Token: 0x170000FB RID: 251
		// (get) Token: 0x060008B7 RID: 2231 RVA: 0x000342E6 File Offset: 0x000324E6
		public ushort ItemID => (ushort)this.brickID;

        // Token: 0x170000FC RID: 252
		// (get) Token: 0x060008B8 RID: 2232 RVA: 0x0000DD30 File Offset: 0x0000BF30
		public byte ItemType => 1;

        // Token: 0x170000FE RID: 254
		// (get) Token: 0x060008BA RID: 2234 RVA: 0x0000DD30 File Offset: 0x0000BF30
		public bool ShowEntityInfo => true;

        // Token: 0x17000102 RID: 258
		// (get) Token: 0x060008BE RID: 2238 RVA: 0x00034327 File Offset: 0x00032527
		public bool hasRepeatBrick => this.repeatBrickId > 0 | this.repeatEvenBrickId > 0 | this.repeatOddBrickId > 0;


        private string name;
		private string nameMesh;

		// Token: 0x060008D3 RID: 2259 RVA: 0x00034424 File Offset: 0x00032624
		public Brick(int id, string name, string nameMesh, ResizeMode resizeMode, params object[] args)
		{
			this.name = name;
			this.resizeMode = resizeMode;
			this.args = args;
			this.nameMesh = nameMesh;
			if (Brick.BRICK_INDEX[id] != null)
			{
			}
			Brick.BRICK_INDEX[id] = this;
			this.brickID = id;
		}


		// Token: 0x060008EB RID: 2283 RVA: 0x00034AE2 File Offset: 0x00032CE2
		public virtual Brick GetBrick()
		{
			return this;
		}

		// Token: 0x04000686 RID: 1670
		public const int BRICK_COUNT = 1024;

		// Token: 0x04000687 RID: 1671
		public const float MIN_GRID_SIZE = 0.125f;

		// Token: 0x04000688 RID: 1672
		public const float MIN_GRID_SIZE_UNIT = 4f;

		// Token: 0x04000689 RID: 1673
		public const int MIN_GRID_HALF_SIZE_UNIT = 2;

		// Token: 0x0400068A RID: 1674
		public const int UNIT_GRID = 3;

		// Token: 0x0400068B RID: 1675
		public const int MAX_GRID = 8;

		// Token: 0x0400068C RID: 1676
		public static Brick[] BRICK_INDEX = new Brick[1024];

		// Token: 0x0400068E RID: 1678
		public readonly int brickID;


		// Token: 0x04000692 RID: 1682
		public float weight = -1f;

		// Token: 0x04000693 RID: 1683
		public int baseWeightUnit = 1;

		// Token: 0x040006A0 RID: 1696
		public bool useMaterial;

		// Token: 0x040006B2 RID: 1714
		public ushort repeatBrickId;

		// Token: 0x040006B3 RID: 1715
		public ushort repeatEvenBrickId;

		// Token: 0x040006B4 RID: 1716
		public ushort repeatOddBrickId;

		// Token: 0x040006B5 RID: 1717
		public bool isRepeatBrick;



		// Token: 0x040006B7 RID: 1719
		public bool isDynamicGridSize;

		// Token: 0x040006B8 RID: 1720
		public int gridSize = 1;


		// Token: 0x040006BA RID: 1722
		public int minGridSize;

		// Token: 0x040006BB RID: 1723
		public int maxGridSize = 8;

		// Token: 0x040006BC RID: 1724
		public int placementSubGrid;


		// Token: 0x040006BE RID: 1726
		public float CollisionWidth = 1f;

		// Token: 0x040006BF RID: 1727
		public float CollisionScaleFactor = 1f;


		// Token: 0x040006C8 RID: 1736
		private readonly ResizeMode resizeMode;

		// Token: 0x040006C9 RID: 1737
		private readonly object[] args;
	}

	public class ResizeMode {
    public static ResizeMode None = new ResizeMode(1f)
    {
      canResize = false
    };
    public static ResizeMode NoneBrick = new ResizeMode(0.25f)
    {
      canResize = false
    };
    public static ResizeMode BlockVertical = new ResizeMode(1f)
    {
      canResize = true,
      maxScale = new Vector3Int(0, 15, 0),
      vertical = true
    };
    public static ResizeMode BlockLateral = new ResizeMode(1f)
    {
      canResize = true,
      maxScale = new Vector3Int(0, 0, 15)
    };
    public static ResizeMode UniformScale = new ResizeMode(1f)
    {
      canResize = true,
      maxScale = new Vector3Int(15, 15, 15),
      linkMode = ResizeMode.LinkMode.uniformScale
    };
    public static ResizeMode BlockFull = new ResizeMode(1f)
    {
      canResize = true,
      maxScale = new Vector3Int(15, 15, 15)
    };
    public static ResizeMode BrickFlat = new ResizeMode(0.25f)
    {
      canResize = true,
      maxScale = new Vector3Int(15, 0, 15)
    };
    public static ResizeMode BrickLateralLarge = new ResizeMode(0.5f)
    {
      canResize = true,
      maxScale = new Vector3Int(0, 0, 3)
    };
    public static ResizeMode BlockFlat = new ResizeMode(1f)
    {
      canResize = true,
      maxScale = new Vector3Int(15, 0, 15)
    };
    public static ResizeMode BrickFull = new ResizeMode(0.25f)
    {
      canResize = true,
      maxScale = new Vector3Int(15, 15, 15)
    };
    public static ResizeMode BrickFullAnchor = new ResizeMode(0.25f)
    {
      canResize = true,
      maxScale = new Vector3Int(15, 15, 15),
      linkMode = ResizeMode.LinkMode.wedgeHeight
    };
    public static ResizeMode GratingBrick = new ResizeMode(1f)
    {
      canResize = true,
      maxScale = new Vector3Int(0, 15, 15)
    };
    public static ResizeMode BrickFlatMedium = new ResizeMode(0.5f)
    {
      canResize = true,
      maxScale = new Vector3Int(7, 0, 7)
    };
    private static readonly Vector3Int BITMASK = new Vector3Int(7, 7, 7);
    private static readonly Vector3Int BITSHIFT = new Vector3Int(0, 3, 6);
    public readonly float unit;
    public Vector3Int maxScale;
    public bool vertical;
    public bool canResize;
    public float thresholdHigh = 1f / 1000f;
    public float thresholdLow = -1f / 1000f;
    public Vector3Int overSize = new Vector3Int(1,1,1);
    public ResizeMode.LinkMode linkMode;

    public int unitStud => (int) (32.0 * (double) this.unit);

    public ResizeMode(float unit) => this.unit = unit;

    public Vector3Int GetScale(int packed) => new Vector3Int(packed >> ResizeMode.BITSHIFT.x & ResizeMode.BITMASK.x, packed >> ResizeMode.BITSHIFT.y & ResizeMode.BITMASK.y, packed >> ResizeMode.BITSHIFT.z & ResizeMode.BITMASK.z);

    public enum LinkMode
    {
      free,
      flat,
      full,
      xy,
      uniformScale,
      wedgeHeight,
      wedgeDiagonal,
      radiusXY,
      radiusXYZ,
    }
  }
}
