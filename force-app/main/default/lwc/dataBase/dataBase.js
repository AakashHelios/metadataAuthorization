import { LightningElement,track } from 'lwc';
const columns = [
    { type: "checkbox", fixedWidth: 50 },
    { label: "Name", fieldName: "name", type: "text" },
    { label: "Metadata Type", fieldName: "Metadata" },
    { label: "Difference Type", fieldName: "Differenceby", type: "text" },
    { label: "Changed on", fieldName: "Date", type: "date" },
    { label: "Changed by", fieldName: "Changedby", type: "text" }
  ];
  
  const datatable = [
    {
      name: "Explorer of the truth",
      Metadata: "Apex class",
      Differenceby: "New",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: "Beatae Architecto beatae",
      Metadata: "Apex class",
      Differenceby: "New",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: "Beatae vitae te",
      Metadata: "Apex class",
      Differenceby: "New",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: "Sed ut perspiciatis ",
      Metadata: "Apex class",
      Differenceby: "No Difference",
      Date: "28-feb-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: "unde omnis iste",
      Metadata: "Apex class",
      Differenceby: "No Difference",
      Date: "23-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    
    {
      name: "Architecto the truth beatae",
      Metadata: "Apex class",
      Differenceby: "No Difference",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: " the truth Architecto beatae",
      Metadata: "Apex class",
      Differenceby: "Deleted",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: "Architecto beatae",
      Metadata: "Apex class",
      Differenceby: "No Difference",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    
    {
      name: "beata123 Architecto",
      Metadata: "Apex class",
      Differenceby: "Different",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: "Architecto ",
      Metadata: "Apex class",
      Differenceby: "Different",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    
    {
      name: "beatae",
      Metadata: "Apex class",
      Differenceby: "Different",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    {
      name: "Helios Web",
      Metadata: "Apex class",
      Differenceby: "Different",
      Date: "28-Jan-2022",
      Changedby: "Aakash",
      selected: false
    },
    
  ];

export default class DataBase extends LightningElement {
@track availableData = [];
@track columns = columns;
@track  selectedItems = [];
searchTerm = "";
@track selectedRows=[];
//im using connectedcallback function  in which i have use json.parse and get data from localstorage
  connectedCallback() {
    const storedData = JSON.parse(localStorage.getItem("datatable"));
    if (storedData) {
      this.availableData = storedData.map((item) => ({
        ...item,
        selected: false
      }));
    } else {
      this.availableData = datatable;
    }
  }

  handleAllitems() {
    this.availableData = datatable;
  }

  handleNewitems() {
    this.availableData = datatable.filter(
      (item) => item.Differenceby === "New"
    );
  }

  handleChangeditem() {
    this.availableData = datatable.filter(
      (item) => item.Differenceby === "Different"
    );
  }

  handleDeleteditem() {
    this.availableData = datatable.filter(
      (item) => item.Differenceby === "Deleted"
    );
  }

  handleSelecteditem() {
    this.availableData = this.selectedItems;
    this.selectedItems = this.availableData.filter((item) => item.selected);
  }

  handleCheckboxChange(event) {
    this.selectedItems = event.detail.selectedRows;
  
  }
  

  handleChange(event) {
    this.searchTerm = event.target.value.toLowerCase();

    if (this.searchTerm === "") {
      this.availableData = datatable;
    } else {
      this.availableData = datatable.filter((item) =>
        item.name.toLowerCase().includes(this.searchTerm)
      );
    }
  }
}console.log(JSON.stringify(event.detail.selectedRows));