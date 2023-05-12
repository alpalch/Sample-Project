/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import LightningModal from 'lightning/modal';

export default class ConfirmMassMarginChange extends LightningModal {

    handleAccept() {
        const acceptEvent = new CustomEvent('massmarginexecute', {detail: 'accept'});
        this.dispatchEvent(acceptEvent);
        this.close();
    }

    handleCancel() {
        this.close();
    }
}