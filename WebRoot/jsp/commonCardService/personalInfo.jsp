<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<script type="text/javascript"> 
	var personalInfoIsFirstLoad = false;
	var personalInfoRegionValue = "";
	var personalInfoTownValue = "";
	var personalInfoCommValue = "";
	$(function(){
		createSysCode({
			id:"personalInfoGender",
			codeType:"SEX",
			value:"0",
			width:160,
			hasDownArrow:false
		});
		createSysCode({
			id:"personalInfoNation",
			codeType:"NATION",
			isShowDefaultOption:false,
			width:160
		});
		$("#personalInfoResideType").combobox({
			width:160,
			valueField:'codeValue',
			editable:false,
		    textField:"codeName",
		    panelHeight:'auto',
		    value:"0",
		    data:[{codeValue:'0',codeName:"本地"},{codeValue:'1',codeName:"外地"}],
		    width:160
		});
		createSysCode({
			id:"personalInfoMarrState",
			codeType:"MARR_STATE",
			width:160
		});
		$("#personalInfoCustomerState").combobox({
			width:160,
			valueField:'codeValue',
			editable:false,
			value:"0",
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'0',codeName:"正常"},{codeValue:'1',codeName:"注销"}]
		});
		$("#personalInfoSureFlag").combobox({
			width:160,
			valueField:'codeValue',
			editable:false,
			value:"0",
		    textField:"codeName",
		    panelHeight:'auto',
		    data:[{codeValue:'0',codeName:"是"},{codeValue:'1',codeName:"否"}]
		});
		createSysCode({
			id:"personalInfoEducation",
			codeType:"EDUCATION",
			value:"99",
			isShowDefaultOption:false,
			width:160
		});
		$.autoComplete({
			id:"personalInfoCorpCustomerId",
			text:"customer_id",
			value:"corp_name",
			table:"base_corp",
			keyColumn:"customer_id",
			minLength:1
		},"personalInfoCorpCustomerName");
		$.autoComplete({
			id:"personalInfoCorpCustomerName",
			text:"corp_name",
			value:"customer_id",
			table:"base_corp",
			keyColumn:"corp_name",
			minLength:"4"
		},"personalInfoCorpCustomerId");
		$("#personalInfoRegionId").combobox({ 
		    url:"commAction!getAllRegion.action",
		    editable:false,
		    cache:true,
		    width:160,
		    valueField:"region_Id",   
		    textField:"region_Name",
	    	onSelect:function(node){
	    		personalInfoIsFirstLoad = false;
	    		personalInfoRegionValue = node.region_Id;
	    		$("#personalInfoTownId").combobox("clear");
	    		$("#personalInfoTownId").combobox("reload","commAction!getAllTown.action?region_Id=" + node.region_Id);
	    	},
	    	onLoadSuccess:function(){
	 			$("#personalInfoTownId").combobox("clear");
	 			$("#personalInfoTownId").combobox("reload","commAction!getAllTown.action?region_Id=" + personalInfoRegionValue);
		    }
		}); 
		$("#personalInfoTownId").combobox({ 
		    editable:false,
		    cache: false,
		    width:160,
		    valueField:"town_Id",   
		    textField:"town_Name",
		    onSelect:function(node){
		    	personalInfoIsFirstLoad = false;
		    	personalInfoTownValue = node.town_Id;
	    		$("#personalInfoCommId").combobox("clear");
	    		$("#personalInfoCommId").combobox("reload","commAction!getAllComm.action?town_Id=" + node.town_Id);
	    	},
	    	onLoadSuccess:function(){
	    		if(personalInfoIsFirstLoad){
		    		$("#personalInfoTownId").combobox("setValue",personalInfoTownValue);
	    		}
	 			$("#personalInfoCommId").combobox("clear");
	 			$("#personalInfoCommId").combobox("reload","commAction!getAllComm.action?town_Id=" + personalInfoTownValue);
		    }
		});
		$("#personalInfoCommId").combobox({ 
		    editable:false,
		    cache: false,
		    width:160,
		    valueField:"comm_Id",   
		    textField:"comm_Name",
		    onLoadSuccess:function(){
		    	if(personalInfoIsFirstLoad){
		 			$("#personalInfoCommId").combobox("setValue",personalInfoCommValue);
		    	}
		    }
		});
	});
	function initPersonalInfo(data){
		personalInfoIsFirstLoad = true;
		$("#personalInfoCustomerId").val(dealNull(data.customerId));
		//1
		$("#personalInfoName").val(data.name);
		$("#personalInfoCertType").combobox("setValue",dealNull(data.certType));
		$("#personalInfoCertNo").val(dealNull(data.certNo));
		//2
		$("#personalInfoPinyin").val(dealNull(data.pinying));
		$("#personalInfoGender").combobox("setValue",dealNull(data.gender));
		$("#personalInfoNation").combobox("setValue",dealNull(data.nation));
		//3
		$("#personalInfoResideType").combobox("setValue",dealNull(data.resideType));
		$("#personalInfoBirthday").val(dealNull(data.birthday));
		$("#personalInfoEducation").combobox("setValue",dealNull(data.education));
		//4
		personalInfoRegionValue = dealNull(data.regionId);
		$("#personalInfoRegionId").combobox("setValue",personalInfoRegionValue);
		$("#personalInfoTownId").combobox("reload","commAction!getAllTown.action?region_Id=" + personalInfoRegionValue);
		personalInfoTownValue = dealNull(data.townId);
		personalInfoCommValue = dealNull(data.commId);
		//5
		$("#personalInfoCustomerState").combobox("setValue",dealNull(data.customerState));
		$("#personalInfoSureFlag").combobox("setValue",dealNull(data.sureFlag));
		$("#personalInfoEmail").val(dealNull(data.email));
		//6
		$("#personalInfoPostCode").val(dealNull(data.postCode));
		$("#personalInfoPhoneNo").val(dealNull(data.phoneNo));
		$("#personalInfoTelNos").val(dealNull(data.TelNos));
		//7
		$("#personalInfoMarrState").combobox("setValue",dealNull(data.marrState));
		$("#personalInfoMobileNo").val(dealNull(data.mobileNo));
		$("#personalInfoMobileNos").val(dealNull(data.mobileNos));
		//8
		$("#personalInfoCareer").val(dealNull(data.career));
		$("#personalInfoCorpCustomerId").val(dealNull(data.corpCustomerId));
		$("#personalInfoCorpCustomerName").val(dealNull(data.regionName));
		//9
		$("#personalInfoResideAddr").val(dealNull(data.resideAddr));
		$("#personalInfoLetterAddr").val(dealNull(data.letterAddr));
		$("#personalInfoNote").html(dealNull(data.note));
	}
	function autoCompletePersonInfo(){
		var certType = $("#personalInfoCertType").combobox("getValue");
		if(certType != "1"){
			return;
		}
		var certNo = $("#personalInfoCertNo").val();
		if(dealNull(certNo) == ""){
			return;
		}
		var birthday = "";
		var gender = "";
		if(certNo.length == 18){
			birthday = certNo.substring(6, 10) + "-" + certNo.substring(10, 12) + "-" + certNo.substring(12, 14);
			gender = parseInt(certNo.substring(16,17)) % 2;
			$("#personalInfoGender").combobox("setValue", gender == 0 ? 2 : 1);
			$("#personalInfoBirthday").val(birthday);
		}
	}
	function personalInfoPhotoUpload() {
		if(dealNull($("#personalInfoCustomerId").val()) == "") {
			$.messager.alert("系统消息","请先查询要修改照片的客户信息！","error");
			return;
		}
		$.modalDialog({
			title:"照片选择导入",
			width:800,
			height:350,
			resizable:false,
			href:"jsp/photoImport/photoSignImportView.jsp",
			onLoad:function(){
				var f = $.modalDialog.handler.find("#form");
				f.form("load", {"personPhotoId": $("#personalInfoCustomerId").val()});
			},
  			buttons:[{
				text:"保存",
				iconCls:"icon-ok",
				handler:function() {
					fileUpload(flushImg);
				}
			},{
				text:"取消",
				iconCls:"icon-cancel",
				handler:function() {
					$.modalDialog.handler.dialog("destroy");
				    $.modalDialog.handler = undefined;
				}
			}]
		});
	}
	function flushImg(){
		$("#personalInfoImgPhoto").attr("src","images/defaultperson.gif")
		imgDeal.getImgMessageByCertNo($("#personalCertNo").val(),function(data){
	 		dwr.util.setValue("personalInfoImgPhoto",data.imageMsg);
	 	});
	}
	function savePersonalInfo(){
		var operType = "1";
		var subTitle = "保存";
		if(dealNull($("#personalInfoCustomerId").val()) != ""){
			subTitle = "编辑";
			operType = "1";
		}else{
			subTitle = "新增";
			operType = "0";
		}
		if(dealNull($("#personalInfoName").val()) == ""){
			$.messager.alert("系统消息","请输入客户姓名！","error",function(){
				$("#personalInfoName").focus();
			});
			return;
		}
		if(dealNull($("#personalInfoCertType").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择客户证件类型！","error",function(){
				$("#personalInfoCertType").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#personalInfoCertNo").val()) == ""){
			$.messager.alert("系统消息","请输入客户证件号码！","error",function(){
				$("#personalInfoCertNo").focus();
			});
			return;
		}
		if(dealNull($("#personalInfoCertNo").val()).length != 18 && $("#personalInfoCertType").combobox("getValue") == "1"){
			$.messager.alert("系统消息","输入证件号码不正确！","error",function(){
				$("#personalInfoCertNo").focus();
			});
			return;
		}
		if(dealNull($("#personalInfoPhoneNo").val()) == "" && dealNull($("#personalInfoMobileNo").val()) == ""){
			$.messager.alert("系统消息","固定电话或手机号码不能为空！","error",function(){
				$("#personalInfoMobileNo").focus();
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要" + subTitle + "客户基本信息吗？",function(r){
			 if(r){
				 $.messager.progress({text:"数据处理中，请稍后...."});
				 $.post("dataAcount/dataAcountAction!toSaveAddOrUpdateBasePersonal.action",$("#personalInfo").serialize() + "&queryType=" + operType,function(data,status){
					 $.messager.progress("close");
					 if(status == "success"){
						 $.messager.alert("系统消息", data.msg, (data.status == "0" ? "info" : "error"),function(){
							 if(data.status == "0"){
								query();
							 }
						 });
					 }else{
						 $.messager.alert("系统消息",subTitle + "客户基本信息出现错误，请重新进行操作！","error");
						 return;
					 }
				 },"json");
			 }
		});
	}
	function getPinYin(){
		commonDwr.getPinYin($("#personalInfoName").val(),function(data){
			if(dealNull(data).length >= 0){
				$("#personalInfoPinyin").val(data);
			}
		});
	}
	
	function photoProcessUpload() {
		if(dealNull($("#personalInfoCustomerId").val()) == "") {
			$.messager.alert("系统消息","请先查询要修改照片的客户信息！","error");
			return;
		}
		$.modalDialog({
			title: "照片处理导入",
			width: 850,
			height: 550,
			resizable: false,
			href: "jsp/photoImport/photoProcessUploadView.jsp",
			onLoad: function() {
				var f = $.modalDialog.handler.find("#form");
				f.form("load", {
					"customerId": $("#personalInfoCustomerId").val()
				});
			},
			buttons:[
			    {
					text: "保存",
					iconCls: "icon-ok",
					handler: function() {
						photoProcessDataUpload();
					}
				}, 
				{
					text: "取消",
					iconCls: "icon-cancel",
					handler: function() {
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
					}
				}
			]
		});
	}
</script>
<div>
	<form id="personalInfo" method="post">	
		<input id="personalInfoCustomerId" name="bp.customerId" type="hidden"/>	
		<table class="tablegrid" style="width:100%">
			<tr>
			    <th class="tableleft" style="width:8%">姓名：</th>
				<td class="tableright"><input id="personalInfoName" name="bp.name" class="textinput" type="text" required="required" onkeyup="getPinYin()" onkeyup="getPinYin()" onkeydown="getPinYin()"  maxlength="30"/></td>
				<th class="tableleft">证件类型：</th>
				<td class="tableright"><input id="personalInfoCertType" name="bp.certType" type="text" class="textinput" required="required"/></td>
				<th class="tableleft">证件号码：</th>
				<td class="tableright"><input id="personalInfoCertNo" name="bp.certNo" class="textinput" type="text" validtype="idcard" required="required" onchange="autoCompletePersonInfo()" onkeyup="autoCompletePersonInfo()" maxlength="18"/></td>
				<td colspan="1" rowspan="5" style="width:150px;text-align:center;">
					<img id="personalInfoImgPhoto" style="width:120px;height:160px;vertical-align:top;" src="images/defaultperson.gif" alt=""/><br/>
				</td>
			</tr>
			<tr>
			 	<th class="tableleft">姓名拼音：</th>
				<td class="tableright"><input id="personalInfoPinyin" name="bp.pinying" class="textinput" required="required" onclick="getPinYin()" maxlength="100"/></td>
				<th class="tableleft">性别：</th>
				<td class="tableright"><input id="personalInfoGender" name="bp.gender" type="text" class="textinput"/></td>
				<th class="tableleft">民族：</th>
				<td class="tableright"><input id="personalInfoNation" name="bp.nation" type="text" class="textinput"/></td>
			</tr>
			<tr>
			 	<th class="tableleft">户籍类型：</th>
				<td class="tableright"><input id="personalInfoResideType" name="bp.resideType" class="textinput" /></td>
			 	<th class="tableleft">出生日期：</th>
				<td class="tableright"><input id="personalInfoBirthday" name="bp.birthday" type="text" class="Wdate textinput" maxlength="8" validtype="date" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})"/></td>
				<th class="tableleft">文化程度：</th>
			 	<td class="tableright"><input id="personalInfoEducation" class="textinput" name="bp.education"/></td>
			</tr>
			<tr>
			    <th class="tableleft">所属区域：</th>
				<td class="tableright"><input id="personalInfoRegionId" name="bp.regionId" class="textinput" type="text"/></td>
				<th class="tableleft">乡镇（街道）：</th>
				<td class="tableright"><input id="personalInfoTownId" name="bp.townId" class="textinput" type="text"/></td>
				<th class="tableleft">社区（村）：</th>
				<td class="tableright"><input id="personalInfoCommId" name="bp.commId" class="textinput" type="text"/></td>
			</tr>
			<tr>
			 	<th class="tableleft">客户状态：</th>
				<td class="tableright"><input id="personalInfoCustomerState" name="bp.customerState" class="textinput"/></td>
				<th class="tableleft">确认标志：</th>
				<td class="tableright"><input id="personalInfoSureFlag" name="bp.sureFlag" class="textinput"/></td>
				<th class="tableleft">电子邮件：</th>
				<td class="tableright"><input id="personalInfoEmail" name="bp.email" type="text" class="textinput" validtype="email" maxlength="32"/></td>
			</tr>
			<tr>
				<th class="tableleft">邮政编码：</th>
				<td class="tableright"><input id="personalInfoPostCode" name="bp.postCode" class="textinput" maxlength="6"/></td>
				<th class="tableleft">固定电话1：</th>
				<td class="tableright"><input id="personalInfoPhoneNo" name="bp.phoneNo" type="text" class="textinput" required="required" validtype="phone" maxlength="22"/></td>
				<th class="tableleft">固定电话2：</th>
				<td class="tableright"><input id="personalInfoTelNos" name="bp.telNos" type="text" class="textinput" validtype="phone" maxlength="22"/></td>
				<td style="text-align:center;"><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-edit"  plain="false" onclick="photoProcessUpload();">修改照片</a></td>
			</tr>
			<tr>
				<th class="tableleft">婚姻状况：</th>
			    <td class="tableright"><input id="personalInfoMarrState" name="bp.marrState" class="textinput" /></td>
				<th class="tableleft">手机号码1：</th>
				<td class="tableright"><input id="personalInfoMobileNo" name="bp.mobileNo" type="text" class="textinput" required="required" validtype="mobile" maxlength="11"/></td>
				<th class="tableleft">手机号码2：</th>
				<td class="tableright"><input id="personalInfoMobileNos" name="bp.mobileNos" type="text" class="textinput" validtype="mobile" maxlength="11"/></td>  
				<td>&nbsp;</td>
			</tr>
			<tr>
			    <th class="tableleft">职业：</th>
				<td class="tableright"><input id="personalInfoCareer" name="bp.career" type="text" class="textinput"/></td>
				<th class="tableleft">单位编号：</th>
				<td class="tableright"><input id="personalInfoCorpCustomerId" name="bp.corpCustomerId" type="text" class="textinput" maxlength="15"/></td>
				<th class="tableleft">单位名称：</th>
				<td class="tableright"><input id="personalInfoCorpCustomerName" name="corpName"  type="text" class="textinput" maxlength="50"/></td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<th class="tableleft">居住地址：</th>
				<td class="tableright" colspan="7"><input id="personalInfoResideAddr"  name="bp.resideAddr" class="textinput" style="width:80%" maxlength="180"/></td>
			</tr>
			<tr>
				<th class="tableleft">联系地址：</th>
				<td class="tableright" colspan="7"><input id="personalInfoLetterAddr"  name="bp.letterAddr" class="textinput" style="width:80%" maxlength="180"/></td>
			</tr>
			<tr>
				<th class="tableleft">备注：</th>
				<td class="tableright" colspan="7"><textarea id="personalInfoNote" name="bp.note" class="textinput" maxlength="200" style="width:80%;height:60px;overflow:hidden;"></textarea></td>
			</tr>
			<tr>
				<td colspan="7" style="text-align:center;height:50px;"><a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="savePersonalInfo()">保存</a></td>
			</tr>
		</table>
	</form>
</div>