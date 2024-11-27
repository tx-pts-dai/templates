interface IActivityMetadata {
    isConfigured:boolean;
}

interface IActivityPayload {
    name: string,
    arguments: any;
    outcomes?: any[];
    errors: any[];
    metaData: IActivityMetadata;
    configurationArguments?: any;
}

export default IActivityPayload;
