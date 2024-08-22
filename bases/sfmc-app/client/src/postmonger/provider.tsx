import React from 'react';
import PostmongetContext from './context';

// @ts-ignore
import Postmonger from 'postmonger';
import IPostmongerSession from './session';

interface IPostmongerProviderProps {
    children: React.ReactNode;
}

const PostmongetProvider = (props:IPostmongerProviderProps) => {
    const session: IPostmongerSession = new Postmonger.Session();

    return (
        <PostmongetContext.Provider value={session}>
            {props.children}
        </PostmongetContext.Provider>
    )
}

export default PostmongetProvider