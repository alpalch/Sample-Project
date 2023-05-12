/**
 * @description       : This is a modal window for adding equipment to proposal.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LightningModal from 'lightning/modal';

import getEquipmentDetails from '@salesforce/apex/ManageEquipmentController.getEquipmentDetails';
import createProposalEquipment from '@salesforce/apex/ManageEquipmentController.createProposalEquipment';

const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';
const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';
const SUCCESS_TOAST_MESSAGE = 'Proposal has been created';

export default class AddEquipmentModal extends LightningModal {
    @api proposalId;
    @api equipmentId;
    equipmentData = {};
    equipmentQuantity = null;

    @wire(getEquipmentDetails, { equipmentId: '$equipmentId' })
        wiredGetCategoryDetails( result ) {
            const { data, error } = result;
                if (data) {
                    this.equipmentData = data;
                }
                if (error) {
                    console.log('error: ', error.message);
                    this.error = error;
                    this.showErrorToast();
                }
        }
    
    handleQuantityChange(event) {
        this.equipmentQuantity = event.detail.value;
    }

    handleSave() {
        const proposalEquipmentData = {
            equipmentName: this.equipmentData.equipmentName,
            equipmentId: this.equipmentId,
            proposalEquipmentQuantity: this.equipmentQuantity
        };
        const JSONproposalEquipmentData = JSON.stringify(proposalEquipmentData);

        createProposalEquipment({ proposalEquipmentData: JSONproposalEquipmentData, proposalId: this.proposalId })
        .then(() => {
            this.showSuccessToast();
            this.close();
        })
        .catch((error) => {
            this.error = error;
            console.log('Error: ', error.message);
            this.showErrorToast();
            this.close();
        });
    }

    handleCancel() {
        this.close();
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: SUCCESS_TOAST_TITLE,
            message: SUCCESS_TOAST_VARIANT,
            variant: SUCCESS_TOAST_MESSAGE,
        });
        this.dispatchEvent(event);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: ERROR_TOAST_VARIANT,
            variant: ERROR_TOAST_MESSAGE,
        });
        this.dispatchEvent(event);
    }
}