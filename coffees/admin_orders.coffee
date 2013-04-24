$ ->
  $("thead tr th input[type='checkbox']").click ->
    jq_checked_inputs().prop("checked", this.checked)

  $("#confirm_handle").click ->
    confirm_checked_order_list()
  $("#unconfirm_handle").click ->
    confirm_checked_order_list("unconfirm")
    
  $(".btn_show_details").click ->
    order_id = parse_order_id(this.id)
    $("#order_details_tr_" + order_id).toggle()

  confirm_checked_order_list = (operation="confirm")->
    order_id_list = checked_order_id_list()
    order_id_list_str = JSON.stringify order_id_list

    $.ajax
      type: 'post'
      url: '/api/orders/confirm'
      data: {"order_id_list": order_id_list_str, "operation": operation, "_method": "PUT" }
      success: (data) ->
        location.reload()
    .fail ->
      alert("状态更换失败")

  checked_order_id_list = ->
    id_list = []
    jq_checked_inputs('checked').each (index, checked_input) ->
      order_id = parse_order_id(checked_input.id)
      id_list.push order_id
    id_list

  jq_checked_inputs = (filter="")->
    checkboxes = $("tbody td.order_number_td input[type='checkbox']")
    if (filter isnt "" && filter is "checked")
      checkboxes = checkboxes.filter (index) ->
        this.checked == true
    checkboxes
  
  parse_order_id = (id)->
    parseInt(id.split('id_')[1], 10)
  
