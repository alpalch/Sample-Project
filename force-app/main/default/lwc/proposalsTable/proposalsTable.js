/**
 * @description       : This component is used to display proposals table
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : @ValeriyPalchenko
**/

import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addProposalModal from 'c/addProposalModal';
import sendProposalModal from 'c/sendProposalModal';

import createNewProposal from '@salesforce/apex/ProposalsTableController.createNewProposal';
import getProposals from '@salesforce/apex/ProposalsTableController.getProposals';
import deleteProposal from '@salesforce/apex/ProposalsTableController.deleteProposal';

export default class ProposalsTable extends NavigationMixin(LightningElement) {

    @api recordId;
    @track error;
    @track retrivedProposals = [];
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
        wiredProposals({data, error}) {
            if(data) {
                this.error = undefined;
                this.retrivedProposals = data.map(element => ({
                    Id: element.Id,
                    Name: element.Name,
                    Status: element.Status__c,
                    Total_Price: element.Total_Price__c,
                    Real_Margin: element.Real_Margin__c,
                    Disabled: element.Status__c == 'Draft' ? false : true
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
        this.proposalSaveData = detail;
        createNewProposal( {equipIds: this.proposalSaveData, OppId: this.recordId} )
            .then((result) => {
                refreshApex(this.wiredProposals);
                this.showSuccessToast('Proposal has been created');
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
                this.handleGetSaveDataEvent(event.detail);
            }
        });
    }  

    handleDeleteProposal(event){
        deleteProposal({ proposalId: event.target.value })
            .then(result => {
                if(result){
                    console.log('Deleted');
                }
            })
            .catch(error => {
                if(error){
                    console.log('Error while deleting proposal');
                    console.log(error);
                }
            })
        window.location.reload(true);
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
            title: 'Error',
            message: 'Something went wrong. Ask your administrator to check logs.',
            variant: 'error',
        });
        this.dispatchEvent(event);
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
        });
        this.dispatchEvent(event);
    }
}