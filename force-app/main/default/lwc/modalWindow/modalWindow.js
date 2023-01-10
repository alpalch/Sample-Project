import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getEquipment from '@salesforce/apex/ModalWindowController.getEquipment';

export default class ModalWindow extends LightningModal {
    @api content;

    handleCloseClick() {
        this.close('canceled');
    }
    
    handleSaveClick() {
      const saveEvent = new CustomEvent('getsavedata', {detail: this.equipmentIds});
      this.dispatchEvent(saveEvent);
      this.close('save');
    }

    @track searchValue;
    @track searchParams;
    @track tableData;
    @track error;
    
    handleSearchValue(event){
      this.searchValue = event.detail;
      if(this.searchValue){
        this.searchParams = this.searchValue.split('/');
      }
      getEquipment({searchCategory: this.searchParams[1], searchEquipment: this.searchParams[0]})
            .then((result) => {
                this.tableData = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.tableData = undefined;
            });
      }

      // Value from Add button
      @track equipmentIds = [];
      disabledButton = true;

      enableButton(){
        if(this.equipmentIds.length > 0){
          this.disabledButton = false;
        }
      }

      handleAddClick(event) {
        this.equipmentIds.push(event.target.value);
        this.enableButton();
      }
}