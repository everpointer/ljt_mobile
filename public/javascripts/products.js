// Generated by CoffeeScript 1.3.3
(function() {

  $(function() {
    return $("form#order").submit(function() {
      var order_details;
      order_details = [];
      $(".checkbox").each(function(index, product) {
        var product_id, quantity, unit_price;
        if (product.checked) {
          product_id = product.id.split('_')[1];
          quantity = $("#quantity_" + product_id).val();
          unit_price = $("#unit_price_" + product_id).attr('value');
          return order_details.push({
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": unit_price
          });
        }
      });
      return $("#order_details").val(JSON.stringify(order_details));
    });
  });

}).call(this);