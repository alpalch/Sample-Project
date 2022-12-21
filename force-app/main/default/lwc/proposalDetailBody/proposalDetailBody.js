import { LightningElement } from 'lwc';
import ModalWindow from 'c/modalWindow';

export default class MyApp extends LightningElement {
    async handleClick() {
        const result = await ModalWindow.open({
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            content: 'Passed into content api',
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
    }
}