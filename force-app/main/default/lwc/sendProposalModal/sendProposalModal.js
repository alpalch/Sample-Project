/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 27-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';
import getContentDocumentId from '@salesforce/apex/ManageProposalsController.getContentDocumentId';
import sendEmailWithAttachment from '@salesforce/apex/ManageProposalsController.sendEmailWithAttachment';
import deleteProposal from '@salesforce/apex/ManageProposalsController.deleteProposal';

const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';
const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const SUCCESS_SENDED_TOAST_MESSAGE = 'Email with proposal was sended';
const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';

export default class sendProposalModal extends LightningModal {
    @api content;
    result;
    error;
    link;

    connectedCallback() {
        //Apex imperative call to avoid DML Exception
        this.getContentDocumentId();
    }

    getContentDocumentId() {
        getContentDocumentId({ proposalId: this.content })
            .then(result => {
                if(result){
                    this.result = result;
                    this.link = '/sfc/servlet.shepherd/document/download/' + result;
                }
            })
            .catch(error => {
                console.log('Error: ', error);
                this.showErrorToast();
            })
    }

    handleSendProposal() {
        sendEmailWithAttachment( {contentDocumentId: this.result, proposalId: this.content} )
            .then(result => {
                if(result){
                    this.showSuccessToast(SUCCESS_SENDED_TOAST_MESSAGE);
                }
            })
            .catch(error => {
                if(error){
                    console.log('Error while sending email: ' + error);
                    this.showErrorToast();
                }
            })
        this.close('Sended and closed');
    }

    handleCancel() {
        deleteProposal( {contentDocumentId: this.result} )
            .then(result => {
                if(result){
                    console.log('Canceled');
                }
            })
            .catch(error => {
                if(error){
                    console.log('Error while canceling preview');
                    console.log(error);
                }
            })
        this.close('Deleted and closed');
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