/*
	Author: Troy Mcilvena (http://troymcilvena.com)
	Twitter: @mcilvena
	Date: 23 August 2010
	Version: 1.0
	
	Revision History:
		1.0 (23/08/2010)	- Initial release.
*/

jQuery.fn.retina = function(retina_part) {
	// Set default retina file part to '-2x'
	// Eg. some_image.jpg will become some_image@2x.jpg
	var settings = {'retina_part': '@2x'};
	if(retina_part) jQuery.extend(config, settings);
		
	if(window.devicePixelRatio >= 2) {
		this.each(function(index, element) {
			if(!$(element).attr('src')) return;
			
			var new_image_src = $(element).attr('src').replace(/(.+)(\.\w{3,4})$/, "$1"+ settings['retina_part'] +"$2");
			$.ajax({url: new_image_src, type: "HEAD", success: function() {
				$(element).attr('src', new_image_src);
			}});
		});
	}
	return this;
}