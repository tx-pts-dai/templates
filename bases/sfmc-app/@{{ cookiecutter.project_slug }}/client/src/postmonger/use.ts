import React from "react"
import PostmongerContext from "./context"

export const usePostmonger = () => {
   const { on, off, end, trigger } = React.useContext(PostmongerContext)

   return {
      on,
      off,
      end,
      trigger,
   }
}
