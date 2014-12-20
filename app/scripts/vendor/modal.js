$(function(){
  var modules = {
    $window: $(window),
    $html: $('html'),
    $body: $('body'),
    $container: $('.aimpr'),

    init: function () {
      $(function () {
        modules.modals.init();
      });
    }

    ,modals: {
      trigger: $('.yo-modal-trigger'),
      trigger_class: '.yo-modal-trigger',
      modal: $('.yo-modal'),
      scrollTopPosition: null,

      init: function () {
        var self = this;
        modules.$body.append('<div class="yo-modal-overlay"></div>');
        self.triggers();
      },

      triggers: function () {
        var self = this;

        modules.$body.on('click', self.trigger_class, function(e) {
          e.preventDefault();
          var $trigger = $(this);
          self.openModal($trigger, $trigger.data('modalId'));
        });

        $('.yo-modal-overlay').on('click', function (e) {
          e.preventDefault();
          self.closeModal();
        });

        modules.$body.on('keydown', function(e){
          if (e.keyCode === 27) {
            self.closeModal();
          }
        });

        $('.yo-modal-close').on('click', function(e) {
          e.preventDefault();
          self.closeModal();
          localStorage['wtf_read'] = true;
        });
      },

      openModal: function (_trigger, _modalId) {
        var self = this,
            scrollTopPosition = modules.$window.scrollTop(),
            $targetModal = $('#' + _modalId);

        self.scrollTopPosition = scrollTopPosition;

        modules.$html
          .addClass('yo-modal-show')
          .attr('data-modal-effect', $targetModal.data('modal-effect'));

        $targetModal.addClass('yo-modal-show');

        modules.$container.scrollTop(scrollTopPosition);
      },

      closeModal: function () {
        var self = this;

        $('.yo-modal-show').removeClass('yo-modal-show');
        modules.$html
          .removeClass('yo-modal-show')
          .removeAttr('data-modal-effect');

        modules.$window.scrollTop(self.scrollTopPosition);
      }
    }
  }

  modules.init();
})
