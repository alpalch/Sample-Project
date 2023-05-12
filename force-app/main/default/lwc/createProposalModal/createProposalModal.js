/**
 * @description       : This is a modal window for creating new proposal.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LightningModal from 'lightning/modal';

import createProposalWithDescription from '@salesforce/apex/ManageProposalsController.createProposalWithDescription';

const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';
const SUCCESS_TOAST_MESSAGE = 'Proposal has been created';
const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';

export default class createProposalModal extends LightningModal {
    @api opportunityId;
    error;
    richTextValue;
    note = '';

    handleSaveProposal() {
        const proposalData = {
            'note': this.note,
            'internalMessage': this.richTextValue,
            'opportunityId': this.opportunityId
        };
        createProposalWithDescription({ proposalData: proposalData })
            .then(() => {
                this.showSuccessToast();
                const successEvent = new CustomEvent('successfulcreatedproposal', { detail: 'success' });
                this.dispatchEvent(successEvent);
                this.close('save');
            })
            .catch((error) => {
                this.showErrorToast();
                this.error = error;
                console.log('Error while creating proposal' + error.message);
                this.close();
            })

    }

    handleCancel() {
        this.close();
    }

    handleRichTextValueChange(event) {
        this.richTextValue = event.target.value;
    }

    handleNoteChange(event) {
        this.note = event.detail.value;
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: SUCCESS_TOAST_TITLE,
            message: SUCCESS_TOAST_MESSAGE,
            variant: SUCCESS_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
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