### This example demonstrates how to use `state_beacon` to manage form state and validation.

Each form field is implemented as a `TextEditingBeacon`, which manages the text input state. Each field also has a corresponding `errorTextBeacon` which is a derived beacon that determines whether to show validation errors in the UI. When the `errorTextBeacon` has a null value, no error is displayed to the user.


<div align='center'>
  <video src='https://github.com/user-attachments/assets/53f74589-bfd4-4f04-a38f-1e4a3585e644' />
</div>

