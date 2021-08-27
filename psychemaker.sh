#!/bin/sh

for PKG in ${PSYCHE_PACKAGES//:/ }; do
  PKGROOTVAR=${PKG}ROOT;

  find ${!PKGROOTVAR} -type f -name "*.hxx" -exec cp \{} ${MACH3}/psycheinc/ \;  
  find ${!PKGROOTVAR} -type f -name "*.so" -exec cp \{} ${MACH3}/lib/ \;   
done
