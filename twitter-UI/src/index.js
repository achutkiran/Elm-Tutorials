import './main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';


var app = Elm.Main.init({
  node: document.getElementById('root')
});

/**
 * Material design js
 */
import {MDCRipple} from '@material/ripple'
import {MDCTextField} from '@material/textfield'
import {MDCTextFieldIcon} from '@material/textfield/icon'

// app.ports.initializeMaterialJS.subscribe( () =>{
  //   console.log("hi")
  //   let textField = document.querySelector('.mdc-text-field')
  //   let textFieldIcon = document.querySelector('.mdc-text-field__icon')
  //   let button = document.querySelector('.mdc-button')
  
  //   if(button)
  //     new MDCRipple(button)
  
  //   if(textField)
  //     new MDCTextField(textField)
  
  //   if(textFieldIcon)
  //     new MDCTextFieldIcon(textFieldIcon)
  // })
  // let textField = document.querySelector('.mdc-text-field')
  // let textFieldIcon = document.querySelector('.mdc-text-field__icon')
  // let button = document.querySelector('.mdc-button')
  
  // if(button)
  //   new MDCRipple(button)
  
  // if(textField)
  //   new MDCTextField(textField)
  
  // if(textFieldIcon)
  // new MDCTextFieldIcon(textFieldIcon)
  //dum() //Donot use calling repetadly
  
  function dum () {
    var observer = new MutationObserver( (mutationList =>{
      console.log(mutationList)
      let button = document.querySelector('.mdc-button')
      let textField = document.querySelector('.mdc-text-field')
      let textFieldIcon = document.querySelector('.mdc-text-field__icon')
      let buttonSelected = false
      let textFieldSelected = false
      let textFieldIconSelected = false
      for( let mutation of mutationList) {
        if(mutation.type == 'childList' && mutation.addedNodes.length != 0) {
          // console.log(mutation.addedNodes)
            // console.log("hi")
            if(button && !buttonSelected){
              console.log("button")
              buttonSelected= true
              new MDCRipple(button)
            }
            
            if(textField && !textFieldSelected){
              console.log("textField")
              textFieldSelected = true
              new MDCTextField(textField)
            }
            
            if(textFieldIcon && !textFieldIconSelected){
              console.log("textFieldIcon")
              textFieldIconSelected = true
              new MDCTextFieldIcon(textFieldIcon)
            }
          }
        }
      }))
      let config = {
        childList : true,
        subtree : true,
        attributes : true
      };

      let target = document.body
      observer.observe(target,config)

  }
//  let button = document.querySelector('.mdc-button')
//  if(button)
//   mdc.ripple.MDCRipple.attachTo(button)

// let textField = document.querySelector('.mdc-text-field')
// if(textField)
//   mdc.textField.MDCTextField.attachTo(textField)

// let matIcon = document.querySelector('.mdc-text-field-icon')
// if(matIcon)
//   mdc.textField.MDCTextFieldIcon.attachTo(matIcon)

registerServiceWorker();
