public class ApexDataClass{
	public cls_attributes attributes;
	public String Id;	//01p5i00000VBWHKAA5
	public String Name;	//SiteLoginController
	public cls_LastModifiedBy LastModifiedBy;
	public cls_CreatedBy CreatedBy;
	public String Body;	///**

    public String Status;	//Active
	class cls_attributes {
		public String type;	//User
		public String url;	///services/data/v58.0/tooling/sobjects/User/0055i00000AwzVTAAZ
	}
	class cls_LastModifiedBy {
		public cls_attributes attributes;
		public String Name;	//Mayank Dhanopia
	}
	class cls_CreatedBy {
		public cls_attributes attributes;
		public String Name;	//Mayank Dhanopia
	}
	public static ApexDataClass parse(String json){
		return (ApexDataClass) System.JSON.deserialize(json, ApexDataClass.class);
	}

}