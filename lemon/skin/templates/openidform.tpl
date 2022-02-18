<div class="form">
  <div class="input-group mb-3">
    <div class="input-group-prepend">
      <span class="input-group-text"><label for="openidfield" class="mb-0"><i class="fa fa-user"></i></label></span>
    </div>
    <input id="openidfield" name="openid_identifier" type="text" class="form-control" trplaceholder="enterOpenIDLogin" aria-required="true"/>
  </div>

  <TMPL_INCLUDE NAME="impersonation.tpl">
  <TMPL_INCLUDE NAME="checklogins.tpl">

  <button type="submit" class="btn btn-success" >
    <span class="fa fa-sign-in"></span>
    <span trspan="connect">Connect</span>
  </button>
</div>
