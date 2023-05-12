/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
import { wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import LightningModal from 'lightning/modal';
import createMembership from '@salesforce/apex/MembershipCertificateController.createMembership';

const ERROR_TOAST_TITLE = 'Error';
const ERROR_TOAST_MESSAGE = 'Something went wrong. Please contact you administrator or try again later.';
const ERROR_TOAST_VARIANT = 'error';
const SUCCESS_TOAST_TITLE = 'Success';
const SUCCESS_TOAST_VARIANT = 'success';
const SUCCESS_TOAST_MESSAGE = 'Success';

export default class MembershipCertificate extends LightningModal {
    recordId;
    error;
    link = '/apex/MembershipCertificate?id=';

    //Get recordId from URL. LWC quick actions don’t pass in recordId in connectedCallback()
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            this.link += this.recordId;
        }
    }

    handleSend() {
        createMembership({ contactId: this.recordId })
            .then((result) => {
                console.log(result);
                if(result === 'Error') {
                    this.showErrorToast();
                }
                else if(result === 'Success') {
                    console.log('Success');
                    this.showSuccessToast();
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch((error) => {
                this.error = error;
                console.log(error);
                this.showErrorToast();
            });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: ERROR_TOAST_TITLE,
            message: ERROR_TOAST_MESSAGE,
            variant: ERROR_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: SUCCESS_TOAST_TITLE,
            message: SUCCESS_TOAST_MESSAGE,
            variant: SUCCESS_TOAST_VARIANT,
        });
        this.dispatchEvent(event);
    }
}