/**
 * @description       : This is a modal window for editing proposal.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import LightningModal from 'lightning/modal';

import getProposal from '@salesforce/apex/ManageProposalsController.getProposal';
import editProposalWithAttachment from '@salesforce/apex/ManageProposalsController.editProposalWithAttachment';

const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';
const SUCCESS_TOAST_MESSAGE = 'Proposal has been updated successfully.';
const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';

export default class createProposalModal extends LightningModal {
    @api proposalId;
    error;
    editProposalName;
    richTextValue;
    note;
    totalCostString;
    totalPriceString;
    marginString;
    buttonLabel = 'Hide Details';
    detailsStyle = '';

    @wire(getProposal, { proposalId: '$proposalId' })
    wiredGetProposal(value) {
        this.wiredProposal =  value;
        const { data, error } = value;
        if(data) {
            this.editProposalName = 'Edit Proposal ' + data.Name;
            this.richTextValue = data.Internal_Message__c;
            this.note = data.Note__c;
            this.totalCostString = 'Total Cost: $' + data.Total_Cost__c;
            this.totalPriceString = 'Total Price: $' + data.Total_Price__c;
            if(data.Real_Margin__c === undefined) {
                this.marginString = 'Margin: 0%'
            } else {
                this.marginString = 'Margin: ' + data.Real_Margin__c + '%';
            }
        }
        if(error) {
            this.showErrorToast();
            this.error = error;
            console.log(this.error.message);
        }
    }

    handleShowHide() {
        if(this.buttonLabel === 'Hide Details') {
            this.buttonLabel = 'Show Details';
            this.detailsStyle = 'display: none;';
        } else {
            this.buttonLabel = 'Hide Details';
            this.detailsStyle = '';
        }
    }    

    handleUpdateProposal() {
        let proposalData = {
            Id: this.proposalId,
            note: this.note,
            internalMessage: this.richTextValue
        };
        editProposalWithAttachment({ proposalData: proposalData })
            .then(() => {
                this.showSuccessToast();
                const successEvent = new CustomEvent('successfulupdatedproposal', { detail: 'success' });
                this.dispatchEvent(successEvent);
                this.close('save');
            })
            .catch((error) => {
                this.showErrorToast();
                this.error = error;
                console.log('Error while editing proposal', error.message);
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
        refreshApex(this.wiredProposal);
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