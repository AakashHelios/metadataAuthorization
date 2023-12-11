import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { LightningElement, track } from "lwc";

const columns = [
  { type: "checkbox", fixedWidth: 50 },
  { label: "Name", fieldName: "name", type: "text" },
  { label: "Metadata Type", fieldName: "Metadata" },
  { label: "Difference Type", fieldName: "Differenceby", type: "text" },
  { label: "Changed on", fieldName: "Date", type: "date" }
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
    name: "Architecto beatae",
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
  }
];
export default class DataTable extends LightningElement {
  @track availableData = datatable;
  @track columns = columns;
  @track preSelectedAllergy = [];
  totalCount = datatable.length;
  selectedItems = [];
  searchTerm = "";
  @track activeTab = "all";
  showsString = false;

  renderedCallback() {
    this.updateButtonLabels();
  }

  updateButtonLabels() {
    const allItemsButton = this.template.querySelector(".all-item-button");
    allItemsButton.label = `All Items (${this.totalCount})`;
    allItemsButton.variant =
      this.activeTab === "all" ? "brand" : "brand-outline";

    const newItemButton = this.template.querySelector(".new-item-button");
    const newItems = datatable.filter((item) => item.Differenceby === "New");
    newItemButton.label = `New Items (${newItems.length})`;
    newItemButton.variant =
      this.activeTab === "new" ? "brand" : "brand-outline";

    const changedButton = this.template.querySelector(".changed-button");
    const changedItems = datatable.filter(
      (item) => item.Differenceby === "Different"
    );
    changedButton.label = `Changed Items (${changedItems.length})`;
    changedButton.variant =
      this.activeTab === "changed" ? "brand" : "brand-outline";

    const deletedButton = this.template.querySelector(".deleted-button");
    const deletedItems = datatable.filter(
      (item) => item.Differenceby === "Deleted"
    );
    deletedButton.label = `Deleted Items (${deletedItems.length})`;
    deletedButton.variant =
      this.activeTab === "deleted" ? "brand" : "brand-outline";

    const selectedButton = this.template.querySelector(
      ".selected-items-button"
    );
    selectedButton.label = `Selected Items (${this.selectedItems.length})`;
    selectedButton.variant =
      this.activeTab === "selected" ? "brand" : "brand-outline";
    selectedButton.variant =
      this.activeTab === "selected" ? "brand" : "brand-outline";
  }

  handleAllItems() {
    this.availableData = datatable;
    this.activeTab = "all";

    //this is for checkbox state
    this.preSelectedAllergy = [];
    this.availableData.forEach((d) => {
      if (this.selectedItems.indexOf(d.name) !== -1) {
        this.preSelectedAllergy.push(d.name);
      }
    });
    this.updateButtonLabels();
  }

  handleNewItems() {
    this.availableData = datatable.filter(
      (item) => item.Differenceby === "New"
    );
    this.activeTab = "new";

    //this is for checkbox state
    this.preSelectedAllergy = [];
    this.availableData.forEach((d) => {
      if (this.selectedItems.indexOf(d.name) != -1) {
        this.preSelectedAllergy.push(d.name);
      }
    });
    this.updateButtonLabels();
  }

  handleChangedItems() {
    this.availableData = datatable.filter(
      (item) => item.Differenceby === "Different"
    );
    this.activeTab = "changed";

    //this is for checkbox state
    this.preSelectedAllergy = [];
    this.availableData.forEach((d) => {
      if (this.selectedItems.indexOf(d.name) != -1) {
        this.preSelectedAllergy.push(d.name);
      }
    });
    this.updateButtonLabels();
  }

  handleDeletedItems() {
    this.availableData = datatable.filter(
      (item) => item.Differenceby === "Deleted"
    );
    this.activeTab = "deleted";
    //this is for checkbox state
    this.preSelectedAllergy = [];
    this.availableData.forEach((d) => {
      if (this.selectedItems.indexOf(d.name) != -1) {
        this.preSelectedAllergy.push(d.name);
      }
    });
    this.updateButtonLabels();
  }

  handleSelectedItems() {
    this.activeTab = "selected";

    console.log("yes");

    console.log(
      this.selectedItems,
      "preSelectedAllergy",
      this.preSelectedAllergy
    );
    //this is for checkbox state
    this.availableData = [];
    this.preSelectedAllergy = [];
    for (let item of datatable) {
      console.log(item);
      if (this.selectedItems.indexOf(item.name) != -1) {
        this.preSelectedAllergy.push(item.name);
        console.log(item);
        this.availableData.push(item);
      }
      console.log(this.selectedItems);
    }
    this.updateButtonLabels();
  }

  handleCheckboxSelection(event) {
    const selectedRows = event.detail.selectedRows;
    const nodifference = selectedRows.some(
      (row) => row.Differenceby === "No Difference"
    );

    if (nodifference) {
      this.showToastMessage("You cannot select rows with 'No Difference'");

      const validRows = selectedRows.filter(
        (row) => row.Differenceby !== "No Difference"
      );
      event.detail.selectedRows = validRows;
    }

    ///
    console.log("Before deSelectedId");
    if (this.preSelectedAllergy.length > event.detail.selectedRows.length) {
      console.log("if");
      let deSelectedId;
      console.log(deSelectedId, "deSelectedId");
      event.detail.selectedRows.forEach((d) => {
        if (this.preSelectedAllergy.indexOf(d.name) == -1) {
          deSelectedId = d.name;
          console.log(deSelectedId, "deSelectedId condition");
          console.log(JSON.stringify(this.deSelectedId));
        }
      });
      this.preSelectedAllergy.splice(
        this.preSelectedAllergy.indexOf(deSelectedId),
        1
      );
      this.selectedItems.splice(this.selectedItems.indexOf(deSelectedId), 1);

      console.log(JSON.stringify(event.detail.selectedRows));
    } else if (
      this.preSelectedAllergy.length < event.detail.selectedRows.length
    ) {
      console.log("test else if");
      this.preSelectedAllergy.push(
        event.detail.selectedRows[event.detail.selectedRows.length - 1].name
      );
      this.selectedItems.push(
        event.detail.selectedRows[event.detail.selectedRows.length - 1].name
      );
      console.log(this.preSelectedAllergy.length);
      console.log(this.selectedItems.length);
    }
    console.log("test");

    // Update the count for selected item
    const selectedButton = this.template.querySelector(
      ".selected-items-button"
    );
    selectedButton.label = `Selected Items (${this.selectedItems.length})`;

    this.updateButtonLabels();
  }
  showToastMessage(message) {
    const toastEvent = new ShowToastEvent({
      title: "Info",
      message: message,
      variant: "info"
    });
    this.dispatchEvent(toastEvent);
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
  handleRowClick() {
    this.showsString = true;
  }
}
