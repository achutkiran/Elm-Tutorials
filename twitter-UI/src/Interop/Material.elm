port module Interop.Material exposing (initMaterial, initializeMaterialJS)

import Json.Encode as E


port initializeMaterialJS : () -> Cmd msg


initMaterial : Cmd msg
initMaterial =
    initializeMaterialJS ()
