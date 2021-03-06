#   (c) Copyright 2015 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
#!!
#! @description: Test if two JSONs are equal.
#! @input json_input1: first JSON input - Example: '{"k1":"v1", "k2": "v2"}'
#! @input json_input2: second JSON input - Example: '{"k2":"v2", "k1": "v1"}'
#! @output return_result: parsing was successful or not
#! @output return_code: "0" if parsing was successful, "-1" otherwise
#! @output error_message: error message if there was an error when executing, empty otherwise
#! @result EQUALS: two JSONs are equal
#! @result NOT_EQUALS: two JSONs are not equal
#! @result FAILURE: parsing was unsuccessful (return_code != '0')
#!!#
####################################################

namespace: io.cloudslang.base.json

operation:
  name: equals
  inputs:
    - json_input1
    - json_input2
  python_action:
    script: |
      try:
        import json, re
        quote1 = None
        quote2 = None

        for c in json_input1:
          if c in ['\'', '\"']:
            quote1 = c
            break
        if quote1 == '\'':
          json_input1 = str(re.sub(r"(?<!\\)(\')",'"', json_input1))
          json_input1 = str(re.sub(r"(\\')",'\'', json_input1))

        for c in json_input2:
          if c in ['\'', '\"']:
            quote2 = c
            break
        if quote2 == '\'':
          json_input2 = str(re.sub(r"(?<!\\)(\')",'"', json_input2))
          json_input2 = str(re.sub(r"(\\')",'\'', json_input2))

        decoded1 = json.loads(json_input1)
        decoded2 = json.loads(json_input2)
        return_code = '0'
        return_result = 'Parsing successful.'
      except Exception as ex:
        return_result = ex
        return_code = '-1'
  outputs:
    - return_result
    - return_code
    - error_message: ${ return_result if return_code == '-1' else '' }
  results:
    - EQUALS: ${ return_code == '0' and decoded1 == decoded2 and quote1 == quote2}
    - NOT_EQUALS: ${ return_code == '0' }
    - FAILURE
