import React from 'react';
import IPostmongerSession from './session';

const PostmongerContext = React.createContext<IPostmongerSession>({} as IPostmongerSession);

export default PostmongerContext;
