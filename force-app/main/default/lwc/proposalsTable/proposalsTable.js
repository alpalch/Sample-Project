/**
 * @description       : This is a modal window component for creating new proposal
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : @ValeriyPalchenko
**/

import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import addProposalModal from 'c/addProposalModal';
import sendProposalModal from 'c/sendProposalModal';

import createNewProposal from '@salesforce/apex/ProposalsTableController.createNewProposal';
import getProposals from '@salesforce/apex/ProposalsTableController.getProposals';
import deleteProposal from '@salesforce/apex/ProposalsTableController.deleteProposal';

export default class ProposalsTable extends NavigationMixin(LightningElement) {

    @track saveValue;
    @api recordId;

    handleGetSaveDataEvent(detail) {
        this.saveValue = detail;
        createNewProposal( {equipIds: this.saveValue, OppId: this.recordId} )
            .then((result) => {
                window.location.reload();
                console.log(result);
                this.error = undefined;
            })
            .catch((error) => {
                console.log(error);
                this.tableData = undefined;
            });
        
      }

    async handleClick() {
        addProposalModal.open({
            size: 'medium',
            description: 'Accessible description of modals purpose',
            content: 'Passed into content api',
            ongetsavedata: (e) => {
                // stop further propagation of the event
                e.stopPropagation();
                this.handleGetSaveDataEvent(e.detail);
            }
        });
    }

    @track wiredProposals = [];
    selectedItemValue;

    @wire(getProposals, { oppId: '$recordId' }) 
        gettedProposals({data, error}){
            if(data){
                this.errors = undefined;
                this.wiredProposals = data.map(element => ({
                    Id: element.Id,
                    Name: element.Name,
                    Status: element.Status__c,
                    Total_Price: element.Total_Price__c,
                    Real_Margin: element.Real_Margin__c,
                    Disabled: true
                }));
                this.wiredProposals.forEach(element => {
                    element.Status == 'Draft' ? element.Disabled = false : element.Disabled = true;
                });
                console.log('Proposals ' + this.wiredProposals);
            }
            if (error){
                this.errors = error;
                this.categories = undefined;
            }
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
            ongetsavedata: (e) => {
                // stop further propagation of the event
                e.stopPropagation();
                this.handleGetSaveDataEvent(e.detail);
            }
        });
    }

    handleGetSaveDataEvent(detail) {
        console.log(detail);
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
}