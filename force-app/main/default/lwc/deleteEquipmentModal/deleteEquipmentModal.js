/**
 * @description       : This is a modal window for deleting equipment from proposal.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LightningModal from 'lightning/modal';

import deleteProposalEquipment from '@salesforce/apex/ManageEquipmentController.deleteProposalEquipment';

const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';
const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const SUCCESS_CREATED_TOAST_MESSAGE = 'Proposal has been deleted';
const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';

export default class deleteProposalModal extends LightningModal {
    @api equipmentId;
    error;

    handleDelete() {
        deleteProposalEquipment({ proposalEquipmentId: this.equipmentId })
            .then(() => {
                this.showSuccessToast(SUCCESS_CREATED_TOAST_MESSAGE);
                const successfulDelete = new CustomEvent('successfulequipmentdelete', { detail: 'success' });
                this.dispatchEvent(successfulDelete);
                this.close();
            })
            .catch((error) => {
                if(error) {
                    this.error = error;
                    console.log('Error while deleting proposal' + error.message);
                    this.showErrorToast();
                    this.close();
                }
            })
    }

    handleCancel() {
        this.close();
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: ERROR_TOAST_MESSAGE,
            variant: ERROR_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: SUCCESS_TOAST_TITLE,
            message: message,
            variant: SUCCESS_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }
}