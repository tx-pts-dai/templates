/**
 * Documentation: Events Broadcast by Journey Builder
 * https://developer.salesforce.com/docs/atlas.en-us.noversion.mc-app-development.meta/mc-app-development/using-postmonger.htm
 */

import IActivityPayload from './activity-payload';
import { usePostmonger } from '../postmonger/use';
import { useCustomActivity } from './custom-activity';

export interface IRequestTokensPayload {
    token: any;
    fuel2token: any;
}

export interface IStep {
    key:string;
    label:string;
}

export const useJourneyBuilder = () => {
    const { on } = usePostmonger();
    const activity = useCustomActivity();

    const onInitActivity = (callback: (payload:IActivityPayload) => void) => on('initActivity', callback);
    const onRequestedTokens = (callback: (payload:IRequestTokensPayload) => void) => on('requestedTokens', callback);
    const onRequestedEndpoints = (callback: (payload:any) => void) => on('requestedEndpoints', callback);
    
    const onClickedNext = (callback: () => void) => on('clickedNext', callback);
    const onClickedBack = (callback: () => void) => on('clickedBack', callback);
    
    const onGotoStep = (callback: (step:IStep) => void) => on('gotoStep', callback);
    const onRequestedCulture = (callback: (cultureCodeString:string) => void) => on('requestedCulture', callback);

    const onRequestedInteractionDefaults  = (callback: (settings:any) => void) => on('requestedInteractionDefaults', callback);
    const onRequestedInteraction  = (callback: (interaction:any) => void) => on('requestedInteraction', callback);
    
    const onRequestedTriggerEventDefinition = (callback: (eventDefinitionModel:any) => void) => on('requestedTriggerEventDefinition', callback);

    return {
        ...activity,
        onGotoStep,
        onClickedNext,
        onClickedBack,
        onInitActivity,
        onRequestedTokens,
        onRequestedCulture,
        onRequestedEndpoints,
        onRequestedInteraction,
        onRequestedInteractionDefaults,
        onRequestedTriggerEventDefinition
    };
}
