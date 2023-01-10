import { LightningElement, track, api } from 'lwc';
import ModalWindow from 'c/modalWindow';
import createNewProposal from '@salesforce/apex/ProposalDetailBodyController.createNewProposal';

export default class MyApp extends LightningElement {

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
        ModalWindow.open({
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
}