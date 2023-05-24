/**
 * @description       : This is a modal window for searching equipment.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LightningModal from 'lightning/modal';

import getEquipmentCategories from '@salesforce/apex/ManageEquipmentController.getEquipmentCategories';
import getEquipments from '@salesforce/apex/ManageEquipmentController.getEquipments';

import addEquipmentModal from 'c/addEquipmentModal';

const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';

const columns = [{ name: 'Equipment Name', width: 'width: 30%', },
                 { name: 'Cost', width: 'width: 10%', },
                 { name: 'Category', width: 'width: 20%', },
                 { name: 'Account', width: 'width: 20%', },
                 { name: 'Description', width: 'width: 40%', }];

export default class SearchEquipmentModal extends LightningModal {
    @api proposalId;
    error;
    columns = columns;
    displayTable = 'display: none';
    selectedCategory = null;
    equipmentName = null;
    categoryOptions = [];
    tableData = [];
    

    @wire(getEquipmentCategories)
        wiredGetEquipmentCategories( result ) {
            const { data, error } = result;
                if (data) {
                this.error = undefined;
                this.categoryOptions = data.map(element => ({ label: element.Name, value: element.Id }));
                this.handleSearch();
                }
                if (error) {
                this.error = error;
                this.showErrorToast();
                }
        }

    handleSearch() {
        getEquipments({ category: this.selectedCategory, equipmentName: this.equipmentName })
        .then((data) => {
            this.tableData = data;
            this.displayTable = this.tableData.length === 0 ? 'display: none' : '';
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.showErrorToast();
            console.log('error: ', error.message);
        });
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.handleSearch();
    }

    handleEquipmentNameChange(event) {
        this.equipmentName = event.detail.value;
        if(this.equipmentName.length > 1) {
            this.handleSearch();
        } else {
            this.equipmentName = '';
            this.handleSearch();
        }
    }

    handleClearFilters() {
        this.template.querySelector('lightning-combobox').value = null;
        this.template.querySelector('lightning-input').value = null;
        this.selectedCategory = null;
        this.equipmentName = null;
        this.handleSearch();
    }

    handleCloseModal() {
        const successEvent = new CustomEvent('successfuladdedequipment', {detail: 'success'});
        this.dispatchEvent(successEvent);
        this.close('save');
    }

    openAddEquipmentModal(event) {
        try {
            addEquipmentModal.open({
                size: 'medium',
                description: 'Add Equipment',
                equipmentId: event.target.value,
                proposalId: this.proposalId,
            });
        } catch (error) {
            console.log('error: ', error.message);
            this.showErrorToast();
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