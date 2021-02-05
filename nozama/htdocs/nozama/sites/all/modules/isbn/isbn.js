Drupal.behaviors.isbn = function(context) {
  $('input.isbn-validate').each(function(){
    var parent = $(this).parent();
    var isbnInput = $(this);
    var translate = Drupal.settings.isbn;
    var monitorDelay = 900;

    //Add message wrapper
    $(this).after("<div class='isbn-validation-message'></div>").parent();
    
    var isbnFormat = isbnInput.attr('isbn-format');
    var isbnMessage = $('div.isbn-validation-message', parent);

    isbnInput.addClass('form-autocomplete');

    //Define Validate function
    var checkISBN = function () {
      // Remove timers for a delayed check if they exist.
      if (this.timer) {
        clearTimeout(this.timer);
      }

      //Do nothing if no input
      if (!isbnInput.val()) {
        isbnMessage.hide();
        return;
      }
      var isbnValue = isbnInput.val();
      
      isbnValidate(isbnValue, isbnFormat);     
    };

    // Define AJAX validate function
    var isbnValidate = function(isbnValue, isbnFormat) {

      //Validate ISBN via Ajax call
      var testURL = Drupal.settings.isbn.validateURL + '/' + isbnFormat + '/' + isbnValue ;
      $.get(testURL, [], function(validISBN){
        validISBN = Drupal.parseJson(validISBN);
        console.log(validISBN);
        
        triggerMessage(validISBN.valid, translate[validISBN.message]);
      });
    };

    var triggerMessage = function(validISBN, message) {
       // Remove styling if it exists
       if (this.confirmClass) {
         isbnMessage.removeClass(this.confirmClass);
       }
       
       // Set validation message and set class
       var confirmClass = validISBN ? "ok" : "error";
       console.log(message);
       if (message) {
         isbnMessage.html(message).addClass(confirmClass);
       } else {
         isbnMessage.html(translate["confirm" + (validISBN ? "Success" : "Failure")]).addClass(confirmClass);
       }
       isbnInput.removeClass('throbbing'); 
       this.confirmClass = confirmClass;
       isbnMessage.show();
    }
    
    // Delayed check
    var delayCheck = function() {
      // Postpone the check since the user is most likely still typing.
      if (this.timer) {
        clearTimeout(this.timer);
      }

      // When the user clears the field, hide the tips immediately.
      if (!isbnInput.val()) {
        isbnMessage.hide();
        isbnInput.removeClass('throbbing');
        return;
      }
      isbnInput.addClass('throbbing');
      // Schedule the actual check.
      this.timer = setTimeout(checkISBN, monitorDelay);
    };

    //Attach Event function
    isbnInput.keyup(delayCheck).change(checkISBN).blur(checkISBN);
  });
}

