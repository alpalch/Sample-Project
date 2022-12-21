import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getProposals from '@salesforce/apex/ProposalDetailBodyController.getProposals';


export default class ProposalDatatable extends NavigationMixin(LightningElement) {
    oppId = this.getOppId();

    getOppId(){
        let oppIdFromURL = window.location.pathname.split('/');
        return oppIdFromURL[oppIdFromURL.length - 2];
    }

    @track proposals;
    @wire(getProposals, { oppId: '$oppId' }) proposals;

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