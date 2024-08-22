export default interface IPostmongerSession {
    end: ()=> void;
    off: (event:string, callback:(data:any) => void, context?:any) => void;
    on: (event:string, callback:(data:any) => void, context?:any) => void;
    trigger: (events:any, payload?:any)=> void;
}