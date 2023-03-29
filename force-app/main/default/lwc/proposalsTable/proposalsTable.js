/**
 * @description       : This component is used to display proposals table
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 28-03-2023
 * @last modified by  : @ValeriyPalchenko
**/

import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import addProposalModal from 'c/addProposalModal';
import sendProposalModal from 'c/sendProposalModal';
import deleteProposalModal from 'c/deleteProposalModal';

import createProposal from '@salesforce/apex/ProposalsTableController.createProposal';
import getProposals from '@salesforce/apex/ProposalsTableController.getProposals';

const ERROR_TOAST_MESSAGE = 'Something went wrong. Ask your administrator to check logs.';
const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_VARIANT = 'error';
const SUCCESS_CREATED_TOAST_MESSAGE = 'Proposal has been created';
const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';

export default class ProposalsTable extends NavigationMixin(LightningElement) {

    @api recordId;
    error;
    retrivedProposals = [];
    proposalSaveData;
    displayTable = 'display: none';
    columns = [
        { name: 'Proposal Number', width: 'width: 20%', },
        { name: 'Total Price', width: 'width: 20%', },
        { name: 'Real Margin', width: 'width: 20%', },
        { name: 'Status', width: 'width: 30%', },
        { name: 'Actions', width: 'width: 10%', }
    ];

    @wire(getProposals, { opportunityId: '$recordId' }) 
        wiredGetProposals(value) {
            this.wiredProposals = value;
            const { data, error } = value;
            if(data) {
                this.error = undefined;
                this.retrivedProposals = data.map(element => ({
                    Id: element.Id,
                    Name: element.Name,
                    Status: element.Status__c,
                    Total_Price: element.Total_Price__c,
                    Real_Margin: element.Real_Margin__c,
                    Disabled: element.Status__c === 'Draft' ? false : true
                }));
                this.retrivedProposals.length > 0 ? this.displayTable = '' : this.displayTable = 'display:none';
            }
            if (error) {
                this.error = error;
                console.log('Error has been happen in wiredProposals. Error: ' + error);
                this.showErrorToast();
            }
        }

    handleSaveProposalData(detail) {
        this.proposalSaveData = Object.values(detail);
        createProposal( {equipmentIds: this.proposalSaveData, opportunityId: this.recordId} )
            .then(() => {
                refreshApex(this.wiredProposals);
                this.showSuccessToast(SUCCESS_CREATED_TOAST_MESSAGE);
            })
            .catch((error) => {
                console.log('Error has been happen in handleSaveProposalData. Error: ' + error);
                this.showErrorToast();
            });
      }

    async handleOpenProposalModal() {
        addProposalModal.open({
            size: 'medium',
            description: 'This is modal window for adding new proposal',
            content: 'Passed into content api',
            onsaveproposaldata: (event) => {
                event.stopPropagation();
                this.handleSaveProposalData(event.detail);
            }
        });
    }  

    async handleDeleteProposal(event) {
        deleteProposalModal.open({
            size: 'small',
            description: 'This is modal window for deleting proposal',
            proposalId: event.target.value,
            onsuccessfulproposaldelete: (closeEvent) => {
                this.handleSuccessfulProposalDelete(closeEvent);
            }
        });
    }

    handleSuccessfulProposalDelete(event) {
        event.stopPropagation();
        if(event.detail === 'successful') {
            refreshApex(this.wiredProposals);
        }
    }

    async handlePreview(event) {
        sendProposalModal.open({
            size: 'medium',
            description: 'Accessible description of modals purpose',
            content: event.target.value,
        });
    }
    
    navigateToProposal(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Proposal__c',
                actionName: 'view'
            }
        });
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