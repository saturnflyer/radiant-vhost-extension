document.observe('dom:loaded',function(){
	$('site_title').observe('keyup', function(event) {
		var input = $('site_hostnames_attributes_0_domain')
		if (input && input.value != '*') {
			var stext = this.value.toLowerCase()
			stext = stext.gsub(/[^a-z0-9-]/, '')		
			stext = stext + ".kuviat.com"
			input.value = stext
		}
	})
  
  $('hostnames').insert({
    after: new Element('p').update(new Element('a',{href: '#', id: 'add_domain'}).update('Add domain')) 
  })
  
	$$('p.hostname').each(function(item, index){ 
		if (index == 0) {
			item.down('input.domain').setAttribute('disabled', 'disabled');
		}	else {
			item.insert({ 
				bottom: new Element('img', {src: '/images/admin/minus.png', className: 'domain_remover'})
			}); 
		}

  });
  
  Event.addBehavior({  
    '#add_domain:click': function(){  
      var new_hostname = $$('#hostnames p.hostname')[0].cloneNode(true)
      var label = $(new_hostname).down('label'); $(label).writeAttribute('id','')
			var input = $(new_hostname).down('input.domain'); $(input).writeAttribute('id',''); $(input).removeAttribute('disabled'); $(input).value = ''
      var destroy = $(new_hostname).down('input.delete_input').remove();
      var new_hostname_id = $(input).identify();
			new_hostname.insert({ 
				bottom: new Element('img', {src: '/images/admin/minus.png', className: 'domain_remover'})
			}); 
      $(label).writeAttribute('for',new_hostname_id)
      $(input).writeAttribute('name','site[hostnames_attributes]['+ $$('input[name*=domain]').size() + '][domain]')
      $(input).writeAttribute('value','')
      $('hostnames').insert({bottom: new_hostname})
      Event.addBehavior.reload()
      return false;
    },
    
    '.domain_remover:click': function(){ 
      p = $(this).up('p.hostname'); 
      var destroyer = p.down('input[name*=destroy]')
      if(destroyer) destroyer.setValue('1');
    
      var removed_element = p.remove()
      if(destroyer) $('hostnames').insert(removed_element.down('input[name*=destroy]'))
    }
  });
  
});