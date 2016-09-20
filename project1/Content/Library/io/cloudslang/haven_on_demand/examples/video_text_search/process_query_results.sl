####################################################
#!!
#! @description: Processes the result of a query to the Haven OnDeman text index.
#!
#! @input query_text: text of the query
#! @input query_result: single result from the query response
#! @output built_results: HTML text containing query results with links
#!!#
####################################################

namespace: io.cloudslang.haven_on_demand.examples.video_text_search

imports:
  comp: io.cloudslang.base.comparisons
  lists: io.cloudslang.base.lists
  strings: io.cloudslang.base.strings
  hod: io.cloudslang.haven_on_demand

flow:
  name: process_query_results

  inputs:
    - query_text
    - query_result
    - item_text:
        default: " "
        private: true

  workflow:
    - find_all:
        do:
          lists.find_all:
            - list: ${query_result['text']}
            - element: ${query_text}
            - ignore_case: "true"
        publish:
          - indices
        navigate:
          - SUCCESS: check_emptiness
    - check_emptiness:
        do:
          comp.equals:
            - first: ${indices}
            - second: ${[]}
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': build_header
    - build_header:
        do:
          strings.append:
            - origin_string: " "
            - text: ${'<h3>' + query_result['title'] + ' - <a href="' + query_result['url'][0] + '">' + query_result['url'][0] + '</a></h3><br><ul>'}
        publish:
          - item_text: ${new_string}
        navigate:
          - SUCCESS: build_result
    - build_result:
        loop:
          for: index in indices
          do:
            hod.examples.video_text_search.build_result:
              - item_text: ${'<h3>' + query_result['title'] + ' - <a href="' + query_result['url'][0] + '">' + query_result['url'][0] + '</a></h3><br><ul>'}
              - query_result
              - index
          break: []
          publish:
            - item_text: ${item_added + '<br>'}
          navigate:
           - SUCCESS: build_footer
    - build_footer:
        do:
          strings.append:
            - origin_string: ${item_text}
            - text: '</ul>'
        publish:
          - item_text: ${new_string}
        navigate:
          - SUCCESS: SUCCESS
  outputs:
    - built_results: ${item_text}
  results:
    - SUCCESS