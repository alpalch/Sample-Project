import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getEquipment from '@salesforce/apex/ModalWindowController.getEquipment';

export default class ModalWindow extends LightningModal {
    @api content;

    handleCloseClick() {
        this.close('canceled');
    }
    
    mitigateSaveFailure() {
        // depending on how easily the failure can be resolved
        // you may need to immediately set disableClose = false
        if (this.failureType === 'recoverable') {
          // no need to call this.disableClose = false
          // or this.saveInProgress = false yet
          tryToFixFailure();
        } else {
          // can't resolve the error
          // need to allow users to exit modal
          this.disableClose = false;
          this.saveInProcess = false;
          // mock function to indicate modal state
          // while still allowing user to exit
          // preventing keyboard trap
          reportUnresolvableError();
        }
    }
    
    async saveData() {
        this.saveInProcess = true;
        const saveStatus = await sendData(this.formData);
        return (saveStatus && saveStatus.success)
        ? closeModal()
        : mitigateSaveFailure();
    }
    
    async handleSaveClick() {
        if (isValid(this.formData)) {
          // begin saving data
          this.disableClose = true;
          await saveData();
        } else {
          // function that display form errors based on data
          showFormErrors(this.formData);
        }
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
                console.log(this.tableData);
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.tableData = undefined;
            });
      }

      @track value = [];
      get options() {
          return [
              { label: 'Add', value: 'true' },
          ];
      }

      get selectedValues() {
          return this.value;
      }

      handleChange(e) {
          this.value = e.detail.value;
      }
}