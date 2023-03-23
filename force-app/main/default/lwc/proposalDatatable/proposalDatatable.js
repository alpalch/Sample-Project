/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import PreviewModal from 'c/previewModal';


import getProposals from '@salesforce/apex/ProposalDatatableController.getProposals';
import deleteProposal from '@salesforce/apex/ProposalDatatableController.deleteProposal';


export default class ProposalDatatable extends NavigationMixin(LightningElement) {
    @api recordId;
    @track wiredProposals = [];
    oppId = this.getOppId();
    selectedItemValue;

    getOppId(){
        let oppIdFromURL = window.location.pathname.split('/');
        return oppIdFromURL[oppIdFromURL.length - 2];
    }

    @wire(getProposals, { oppId: '$oppId' }) 
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
        PreviewModal.open({
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