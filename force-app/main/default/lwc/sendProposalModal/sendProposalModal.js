/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getContentDocumentId from '@salesforce/apex/PreviewModalController.getContentDocumentId';
import sendEmailWithAttachment from '@salesforce/apex/PreviewModalController.sendEmailWithAttachment';
import closePreview from '@salesforce/apex/PreviewModalController.closePreview';
import ContactMobile from '@salesforce/schema/Case.ContactMobile';

export default class PreviewModal extends LightningModal {
    @api content;
    @track result;
    @track errors;
    @track link;

    getContentDocumentId(){
        getContentDocumentId({ proposalId: this.content })
            .then(result => {
                if(result){
                    this.result = result;
                    this.link = '/sfc/servlet.shepherd/document/download/' + result;
                    console.log('Success');
                }
            })
            .catch(error => {
                console.log('Error getting ContentDocumentId');
                console.log('Error: ', error);
            })
    }

    connectedCallback() {
        //Apex imperative call to avoid DML Exception
        this.getContentDocumentId();
    }

    handleSendClick(){
        sendEmailWithAttachment( {contentDocumentId: this.result, proposalId: this.content} )
            .then(result => {
                if(result){
                    console.log('Sended');
                }
            })
            .catch(error => {
                if(error){
                    console.log('Error while sending email');
                    console.log(error);
                }
            })
        this.close('Sended and closed');
    }

    handleCancelClick(){
        closePreview( {contentDocumentId: this.result} )
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
}