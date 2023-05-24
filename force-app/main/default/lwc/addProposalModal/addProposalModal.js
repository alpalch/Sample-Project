/**
* @description       : This is a modal window for adding new proposal.
* @author            : @ValeriyPalchenko
* @group             : 
* @last modified on  : 24-05-2023
* @last modified by  : @ValeriyPalchenko
**/
import { wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LightningModal from 'lightning/modal';

import getEquipment from '@salesforce/apex/ManageProposalsController.getEquipment';
import getEquipmentCategories from '@salesforce/apex/ManageProposalsController.getEquipmentCategories';

const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';
const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';

const columns = [{ name: 'Equipment Category', width: 'width: 30%', },
                 { name: 'Product Name', width: 'width: 30%', },
                 { name: 'Amount', width: 'width: 20%', },
                 { name: 'Select', width: 'width: 20%', },];

export default class addProposalModal extends LightningModal {
    
    tableData;
    error;
    selectedCategory;
    equipmentName;
    equipmentIds = [];
    categoryOptions = [];
    isSaveButtonDisabled = true;
    displayTable = 'display: none';
    columns = columns;

    @wire(getEquipmentCategories)
    wiredGetEquipmentCategories( result ) {
    const { data, error } = result;
        if (data) {
            this.error = undefined;
            // data.forEach(element => this.categoryOptions.push( {label: element.Name, value: element.Id} ));
            this.categoryOptions = data.map(element => ({ label: element.Name, value: element.Id }));
        }
        if (error) {
            this.error = error;
            this.showErrorToast();
        }
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
    }

    handleEquipmentNameChange(event) {
        this.equipmentName = event.detail.value;
    }

    handleEquipmentSearch() {
        getEquipment({ searchCategory: this.selectedCategory, searchEquipment: this.equipmentName })
        .then((result) => {
            this.tableData = result;
            this.displayTable = this.tableData.length > 0 ? '' : 'display:none';
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            console.log('handleEquipmentSearch error: ', error);
            this.showErrorToast();
        });
        
    }

    handleAddClick(event) {
        this.equipmentIds.push(event.target.value);
        this.enableSaveButton();
    }

    handleCloseClick() {
        this.close('canceled');
    }

    handleSaveClick() {
        const saveEvent = new CustomEvent('saveproposaldata', { detail: this.equipmentIds });
        this.dispatchEvent(saveEvent);
        this.close('save');
    }
    
    enableSaveButton() {
        if(this.equipmentIds.length > 0) {
        this.isSaveButtonDisabled = false;
        }
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: ERROR_TOAST_MESSAGE,
            variant: ERROR_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }
}