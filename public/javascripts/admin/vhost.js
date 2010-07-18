document.observe('dom:loaded',function(){
  
  $('hostnames').insert({
    after: new Element('p').update(new Element('a',{href: '#', id: 'add_domain'}).update('Add domain')) 
  })
  
  $$('p.hostname').each(function(item){ 
    item.insert({ 
      bottom: new Element('img', {src: '/images/admin/minus.png', className: 'domain_remover'})
    }); 
  });
  
  Event.addBehavior({  
    '#add_domain:click': function(){  
      var new_hostname = $$('#hostnames p.hostname')[0].cloneNode(true)
      var label = $(new_hostname).down('label'); $(label).writeAttribute('id','')
      var input = $(new_hostname).down('input.domain'); $(input).writeAttribute('id','')
      var destroy = $(new_hostname).down('input.delete_input').remove();
      var new_hostname_id = $(input).identify();
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