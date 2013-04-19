$ ->
  $("form#order").submit ->
    order_details = []
    $(".checkbox").each (index, product) ->
      if product.checked
        product_id = product.id.split('_')[1]
        quantity = $("#quantity_" + product_id).val()
        unit_price = $("#unit_price_" + product_id).attr('value')
        order_details.push(
          {"product_id": product_id, "quantity": quantity, "unit_price": unit_price})

    $("#order_details").val JSON.stringify(order_details)
