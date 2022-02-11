<TMPL_IF NAME="TOKEN">
<input id="token" type="hidden" name="token" value="<TMPL_VAR NAME="TOKEN">" />
</TMPL_IF>

<TMPL_IF NAME="WAITING_MESSAGE">
<div class="alert alert-info"><span trspan="waitingmessage" ></span></div>
<TMPL_ELSE>
<div class="form">
  <div class="input-group mb-3">
    <div class="input-group-prepend">
      <span class="input-group-text"><label for="userfield" class="mb-0"><i class="fa fa-user"></i></label></span>
    </div>
    <div class="flapskin-username-login-input-container">
    <input id="userfield" name="user" type="text" autocomplete="username" class="form-control" value="<TMPL_VAR NAME="LOGIN">" trplaceholder="login" required aria-required="true"/>
		<div class="form-control flapskin-username-login-input-domain">@<TMPL_VAR NAME="primary_domain_name"></div>
  </div>
  </div>
  <div class="input-group mb-3">
    <div class="input-group-prepend">
      <span class="input-group-text"><label for="passwordfield" class="mb-0"><i class="fa fa-lock"></i></label></span>
    </div>
    <TMPL_IF NAME="DONT_STORE_PASSWORD">
      <input id="passwordfield" name="password" type="text" class="form-control" trplaceholder="password" autocomplete="off" required aria-required="true" aria-hidden="true"/>
      <TMPL_IF NAME="ENABLE_PASSWORD_DISPLAY">
        <div class="input-group-append">
          <span class="input-group-text"><i class="fa fa-eye-slash toggle-password"></i></span>
        </div>
      </TMPL_IF>
    <TMPL_ELSE>
      <input id="passwordfield" name="password" type="password" autocomplete="current-password" class="form-control" trplaceholder="password" required aria-required="true"/>
      <TMPL_IF NAME="ENABLE_PASSWORD_DISPLAY">
        <div class="input-group-append">
          <span class="input-group-text"><i class="fa fa-eye-slash toggle-password"></i></span>
        </div>
      </TMPL_IF>
    </TMPL_IF>
  </div>

  <TMPL_IF NAME=CAPTCHA_SRC>
    <TMPL_INCLUDE NAME="captcha.tpl">
  </TMPL_IF>

  <TMPL_INCLUDE NAME="impersonation.tpl">
  <TMPL_INCLUDE NAME="checklogins.tpl">

  <button type="submit" class="btn btn-success green solid flapskin-success-button" >
    <span class="fa fa-sign-in"></span>
    <span trspan="connect">Connect</span>
  </button>
</div>

<div class="actions flapskin-flex">
  <TMPL_IF NAME="DISPLAY_RESETPASSWORD">
  <a class="btn btn-secondary red no-outline small flapskin-no-margin" href="<TMPL_VAR NAME="MAIL_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
    <span class="fa fa-info-circle"></span>
    <span trspan="resetPwd">Reset my password</span>
  </a>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_UPDATECERTIF">
     <a class="btn btn-secondary" href="<TMPL_VAR NAME="MAILCERTIF_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
        <span class="fa fa-refresh"></span>
        <span trspan="certificateReset">Reset my certificate</span>
     </a>
   </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_FINDUSER">
    <button type="button" class="btn btn-secondary" data-toggle="modal" data-target="#finduserModal">
      <span class="fa fa-search"></span>
      <span trspan="searchAccount">Search for an account</span>
    </button>
  </TMPL_IF>

  <TMPL_IF NAME="DISPLAY_REGISTER">
    <a class="btn btn-secondary green no-outline small flapskin-no-margin" href="<TMPL_VAR NAME="REGISTER_URL">?skin=<TMPL_VAR NAME="SKIN"><TMPL_IF NAME="key">&<TMPL_VAR NAME="CHOICE_PARAM">=<TMPL_VAR NAME="key"></TMPL_IF><TMPL_IF NAME="AUTH_URL">&url=<TMPL_VAR NAME="AUTH_URL"></TMPL_IF>">
      <span class="fa fa-plus-circle"></span>
      <span trspan="createAccount">Create an account</span>
    </a>
  </TMPL_IF>

</div>
</TMPL_IF>
