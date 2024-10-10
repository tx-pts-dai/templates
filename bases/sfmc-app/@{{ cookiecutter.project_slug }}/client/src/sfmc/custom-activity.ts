/**
 * Documentation - Events Broadcast by the Custom Activity
 * https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-app-development.meta/mc-app-development/using-postmonger.htm
 */

import { usePostmonger } from '../postmonger/use';
import IActivityPayload from './activity-payload';

export interface IStep {
    key:string;
    label:string;
    active:boolean;
}

export type Button = 'next' | 'back';

export interface IButton {
    visible?: boolean; 
    enabled?: boolean;
    text?:  "next" | "done";
    button: Button;
}



export const useCustomActivity = () => {
    const { trigger } = usePostmonger();

    const ready = () => trigger('ready');
    const requestTokens = () => trigger('requestTokens');
    const requestEndpoints = () => trigger('requestEndpoints');

    const nextStep = () => trigger('nextStep');
    const previousStep = () => trigger('prevStep');

    const requestCulture = () => trigger('requestCulture');

    const updateSteps = (steps: IStep[]) => trigger('updateSteps', steps);

    const updateButton = (button: IButton) => trigger('updateButton', button);
    const enableButton = (button: Button): void  => updateButton({
        button,
        enabled: true
    });

    const disableButton = (button: Button): void  => updateButton({
        button,
        enabled: false
    });


    const destroy = () => trigger('destroy');
    const update = (payload:IActivityPayload) => trigger('updateActivity', payload);

    const requestInteraction = () => trigger('requestInteraction');
    const requestInteractionDefaults = () => trigger('requestInteractionDefaults');
    const requestTriggerEventDefinition = () => trigger('requestTriggerEventDefinition');
    
    return {
        ready,
        update,
        destroy,
        nextStep,
        updateSteps,
        updateButton,
        enableButton,
        disableButton,
        previousStep,
        requestTokens,
        requestCulture,
        requestEndpoints,
        requestInteraction,
        requestInteractionDefaults,
        requestTriggerEventDefinition
    };
}
