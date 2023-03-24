/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getEquipment from '@salesforce/apex/ManageProposalsController.getEquipment';
import getEquipmentCategories from '@salesforce/apex/ManageProposalsController.getEquipmentCategories';

export default class ModalWindow extends LightningModal {
  @api content;
  @track searchValue;
  @track searchParams;
  @track tableData;
  @track error;
  // Value from Add button
  @track equipmentIds = [];
    
  disabledButton = true;

  handleCloseClick() {
    this.close('canceled');
  }
    
  handleSaveClick() {
    const saveEvent = new CustomEvent('getsavedata', {detail: this.equipmentIds});
    this.dispatchEvent(saveEvent);
    this.close('save');
  }


    
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

  handleAddClick(event) {
    this.equipmentIds.push(event.target.value);
    this.enableButton();
  }

  enableButton(){
    if(this.equipmentIds.length > 0){
      this.disabledButton = false;
    }
  }
  errors;
    selectedCategory;
    textEquipmentName;
    clickedButtonLabel;
    categories =[];
    
    @wire(getEquipmentCategories)
    transformDataForOptions({data, error}){
        if(data){
            this.errors = undefined;
           // data.forEach(element => this.categories.push( {label: element.Name, value: element.Id} ));
            this.categories = data.map(element => ({ label: element.Name, value: element.Id }));
        }
        if (error){
            this.errors = error;
            this.categories = undefined;
        }
    }

    handleChange(event) {
        this.selectedCategory = event.detail.value;
    }

    handleInputFocus(event) {
        // modify parent to properly highlight visually
        const classList = event.target.parentNode.classList;
        classList.add('lgc-highlight');
    }

    handleInputBlur(event) {
        // modify parent to properly remove highlight
        const classList = event.target.parentNode.classList;
        classList.remove('lgc-highlight');
    }

    handleInputChange(event) {
        this.textEquipmentName = event.detail.value;
    }

    handleClick(event) {
        this.clickedButtonLabel = this.textEquipmentName + '/' + this.selectedCategory;
        const searchEvent = new CustomEvent('getsearchvalue', {detail: this.clickedButtonLabel});
        this.dispatchEvent(searchEvent);
    }
}