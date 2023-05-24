/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import LightningModal from 'lightning/modal';

import searchEquipmentModal from 'c/searchEquipmentModal';
import deleteEquipmentModal from 'c/deleteEquipmentModal';
import confirmMassMarginChange from 'c/confirmMassMarginChange';

import getEquipmentsForProposal from '@salesforce/apex/ManageEquipmentController.getEquipmentsForProposal';
import updateProposalEquipments from '@salesforce/apex/ManageEquipmentController.updateProposalEquipments';
import massMarginUpdate from '@salesforce/apex/ManageEquipmentController.massMarginUpdate';

const actions = [
    {label: 'Delete',name: 'delete', iconName: 'action:delete'},
];

const columns = [
    {label: 'Equipment Name', fieldName: 'proposalEquipmentName', type: 'text', editable: 'true'},
    {label: 'Quantity', fieldName: 'proposalEquipmentQuantity', type: 'number', typeAttributes: {}, editable: 'true'},
    {label: 'Cost', fieldName: 'proposalEquipmentCost', type: 'currency', editable: 'true'},
    {label: 'Price', fieldName: 'proposalEquipmentPrice', type: 'currency'},
    {label: 'Total Price', fieldName: 'TotalPrice', type: 'currency'},
    {label: 'Margin', fieldName: 'proposalEquipmentMargin', type: 'percent', typeAttributes: {step: '0.00001', minimumFractionDigits: '2', maximumFractionDigits: '3',}, editable: 'true',},
    {type: 'action', typeAttributes: {rowActions: actions, menuAlignment: 'right'}}
];

const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';
const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';
const SUCCESS_TOAST_MESSAGE = 'Successfully updated';

export default class EditProposalTableModal extends LightningModal {
    @api proposalId;
    error;
    columns = columns;
    tableData = [];

    @wire(getEquipmentsForProposal, { proposalId: '$proposalId' })
        wiredGetEquipmentsForProposal(value) {
            this.wiredEquipmentsForProposal = value;
            const { data, error } = value;
            if(data) {
                this.tableData = JSON.parse(data);
                this.tableData.forEach(proposalEquipment => {
                    proposalEquipment.proposalEquipmentMargin = proposalEquipment.proposalEquipmentMargin / 100;
                    proposalEquipment.TotalPrice = proposalEquipment.proposalEquipmentPrice * proposalEquipment.proposalEquipmentQuantity;
                });
            }
            if(error) {
                this.error = error;
                console.log('Error at @wire function', this.error.message);
                this.showErrorToast();
            }
        }

    handleOpenAddEquipmentModal(event) {
        searchEquipmentModal.open({
            size: 'medium',
            description: 'This is modal window for adding equipment',
            proposalId: event.target.value,
            onsuccessfuladdedequipment: (saveEvent) => {
                saveEvent.stopPropagation();
                this.refreshTable(saveEvent.detail);
            }
        });
    }

    handleSave(event) {
        const draftValues = event.detail.draftValues;
        updateProposalEquipments({ jsonData: JSON.stringify(draftValues) })
            .then(() => {
                this.showSuccessToast();
                this.refreshTable('success');
            })
            .catch(error => {
                this.error = error;
                console.log('error: ', this.error);
                for(let i = 0; i < this.error.body.pageErrors.length; i++) {
                    this.showErrorToast(this.error.body.pageErrors[i].message);
                }
                for(let i = 0; i < this.error.body.fieldErrors.Margin__c.length; i++) {
                    this.showErrorToast(this.error.body.fieldErrors.Margin__c[i].message);
                }
            });
    }

    handleRowActions(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch(actionName) {
            case 'delete':
                this.handleOpenDeleteEquipmentModal(row.proposalEquipmentId);
                break;
            default:
                this.showErrorToast();
        }
    }

    handleOpenDeleteEquipmentModal(equipmentId) {
        deleteEquipmentModal.open({
            size: 'medium',
            description: 'This is modal window for deleting equipment',
            equipmentId: equipmentId,
            onsuccessfulequipmentdelete: (saveEvent) => {
                saveEvent.stopPropagation();
                this.refreshTable(saveEvent.detail);
            }
        });
    }

    handleCloseModal() {
        const successEvent = new CustomEvent('successfulupdatedequipment', {detail: 'success'});
        this.dispatchEvent(successEvent);
        this.close('save');
    }

    handleMassMarginClick() {
        confirmMassMarginChange.open({
            size: 'small',
            description: 'This is modal window for mass margin update confirmation',
            onmassmarginexecute: (saveEvent) => {
                saveEvent.stopPropagation();
                this.massMarginExecute(saveEvent.detail);
            }
        });
    }

    massMarginExecute(key) {
        if(key === 'accept') {
            const marginValue = this.template.querySelector('lightning-input').value;
            this.tableData.forEach(proposalEquipment => {
                proposalEquipment.proposalEquipmentMargin = marginValue;
            });
            const jsonProposalEquipmentData = JSON.stringify(this.tableData);
            massMarginUpdate({ proposalEquipmentData: jsonProposalEquipmentData })
                .then(() => {
                    this.refreshTable('success');
                })
                .catch(error => {
                    this.error = error;
                    console.log('error: ', this.error);
                    for(let i = 0; i < this.error.body.pageErrors.length; i++) {
                        this.showErrorToast(this.error.body.pageErrors[i].message);
                    }
                    for(let i = 0; i < this.error.body.fieldErrors.Margin__c.length; i++) {
                        console.log('error: ', this.error.body.fieldErrors.Margin__c[i].message);
                        this.showErrorToast(this.error.body.fieldErrors.Margin__c[i].message);
                    }
                });
        }
    }

    refreshTable(key) {
        if(key === 'success') {
            refreshApex(this.wiredEquipmentsForProposal);
        }
    }

    showErrorToast(errorMessage) {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: errorMessage ? errorMessage : ERROR_TOAST_MESSAGE,
            variant: ERROR_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: SUCCESS_TOAST_TITLE,
            message: SUCCESS_TOAST_MESSAGE,
            variant: SUCCESS_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }
}