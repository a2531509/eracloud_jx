<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<style>
#address2{
	width: 100%;
}
</style>
<script type="text/javascript">
	$(function() {
		$.addIdCardReg("conCertNo");
		
		$("#certType2").combobox({
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CERT_TYPE",
			valueField:"codeValue",
			textField:"codeName",
			editable:false,
			panelHeight: 'auto',
			loadFilter:function(data){
				if(data.status != "0"){
					$.messager.alert("系统消息",data.msg,"warning");
					$("#certType2").combobox("disable");
				}
				return data.rows;
			},
			onLoadSuccess : function() {
				$("#certType2").combobox("setValue", $("#certType3").val());
			},
			onSelect : function(record) {
				$("#certType3").val(record.codeValue);
			}
		});
		
		$("#corpType2").combobox({
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CORP_TYPE",
			valueField:"codeValue",
			textField:"codeName",
			editable:false,
			panelHeight: 'auto',
			loadFilter:function(data){
				if(data.status != "0"){
					$.messager.alert("系统消息",data.msg,"warning");
					$("#corpType2").combobox("disable");
				}
				return data.rows;
			},
			onLoadSuccess : function() {
				$("#corpType2").combobox("setValue", $("#corpType3").val());
			},
			onSelect : function(record) {
				$("#corpType3").val(record.codeValue);
			}
		});
		
		$("#regionId2").combobox({
			url:"commAction!getAllRegion.action",
			valueField:"region_Id",
			textField:"region_Name",
			editable:false,
			panelHeight: 'auto',
			onLoadSuccess : function() {
				$("#regionId2").combobox("setValue", $("#regionId3").val());
			},
			onSelect : function(record) {
				$("#regionId3").val(record.codeValue);
			}
		});

		$("#carrefFlag2").combobox({
			labelField : "value",
			textField : "name",
			panelHeight : "auto",
			editable : false,
			value : "1",
			data : [ {
				value : "0",
				name : "是"
			}, {
				value : "1",
				name : "否"
			} ]
		});

		$("#form").form({
			url : "corpManager/corpManagerAction!saveCorpInfo.action",
			onSubmit : function() {
				if(!$("#form").form("validate")){
					return false;
				}
			},
			success : function(data) {
				var info = JSON.parse(data);

				if (info.status == 0) {
					$.messager.alert("消息提示", "单位信息保存成功", "info");
					$.modalDialog.handler.dialog('destroy');
					$.modalDialog.handler = undefined;
				} else {
					$.messager.alert("消息提示", info.errMsg, "error");
				}
			}
		});
	});
	
	function autoCom(){
        if($("#pCustomerId2").val() == ""){
            $("#pCorpName2").val("");
        }
        $("#pCustomerId2").autocomplete({
            source: function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"customerId":$("#pCustomerId2").val()},function(data){
                    response($.map(data.rows,function(item){return {label:item.LABEL,value:item.TEXT}}));
                },'json');
            },
            select: function(event,ui){
                $('#pCustomerId2').val(ui.item.label);
                $('#pCorpName2').val(ui.item.value);
                return false;
            },
              focus:function(event,ui){
                return false;
              }
        }); 
    }
	
	function autoComByName(){
        if($("#pCorpName2").val() == ""){
            $("#pCustomerId2").val("");
        }
        $("#pCorpName2").autocomplete({
            source:function(request,response){
                $.post('corpManager/corpManagerAction!initAutoComplete.action',{"corpName":$("#pCorpName2").val()},function(data){
                    response($.map(data.rows,function(item){return {label:item.TEXT,value:item.LABEL}}));
                },'json');
            },
            select: function(event,ui){
                $('#pCustomerId2').val(ui.item.value);
                $('#pCorpName2').val(ui.item.label);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }
	
	//证件号码校验
	function addCertNo(elementId){
		var targetEle_ = elementId;
		if(typeof(targetEle_) == 'undefined'){
			return;
		}
		targetEle_.onkeydown = function(){
			if($("#certType2").combobox("getValue") != "1"){
				return;
			}
			var _reg = /^\d{0,17}([0-9]?|[Xx]?)$/g;
			if(!_reg.test(this.value)){
				targetEle_.value = targetEle_.value.substring(0,targetEle_.value.length - 1);
			}
		}
		targetEle_.onkeyup = function(){
			if($("#certType2").combobox("getValue") != "1"){
				return;
			}
			var _reg = /^\d{0,17}([0-9]?|[Xx]?)$/g;
			if(!_reg.test(this.value)){
				targetEle_.value = targetEle_.value.substring(0,targetEle_.value.length - 1);
			}
		}
		//onkeydown="addCertNo(this)" onkeyup="addCertNo(this)"
	}
	function readIdCard2(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["name"]) == ""){
			return;
		}else{
			$("#contact2").val(certinfo["name"]);
			$("#conCertNo").val(certinfo["cert_No"]);
		}
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#contact2").val(dealNull(queryCertInfo["name"]));
		$("#conCertNo").val(dealNull(queryCertInfo["cert_No"]));
	}
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false"
		style="overflow: auto; padding: 0px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<input type="hidden" id="corpType3" name="corp.corpType" value="${corp.corpType}" />
			<input type="hidden" id="certType3" name="corp.certType" value="${corp.certType}" />
			<input type="hidden" id="regionId3" name="corp.regionId" value="${corp.regionId}" />
			<input type="hidden" name="corp.customerId" value="${corp.customerId}"/>
			<table class="tablegrid" style="width: 100%">
				<tbody>
					<tr>
						<td colspan="6"><h3 class="subtitle">单位基本信息</h3></td>
					</tr>
					<tr>
						<th class="tableleft">单位名称：</th>
						<td class="tableright"><input name="corp.corpName"
							class="textinput easyui-validatebox" id="corpName2" type="text"
							value="${corp.corpName}" maxlength="128" data-options="required:true,missingMessage:'集团客户名称',invalidMessage:'集团客户名称'"/></td>
						<th class="tableleft">单位简称：</th>
						<td class="tableright"><input name="corp.abbrName"
							id="abbrName2" type="text" class="textinput"
							value="${corp.abbrName}"/></td>
						<th class="tableleft">单位类型：</th>
						<td class="tableright"><input
							class="textinput" id="corpType2"
							value="${corp.corpType}"
							/></td>
					</tr>
					<tr>
						<th class="tableleft">营业执照编号：</th>
						<td class="tableright"><input name="corp.licenseNo" id="licenseNo2" type="text" value="${corp.licenseNo}" class="textinput"/></td>
						<th class="tableleft">上级单位编号：</th>
						<td class="tableright"><input id="pCustomerId2" name="corp.PCustomerId" type="text" class="textinput" maxlength="15" value="${corp.PCustomerId}" onkeyup="autoCom()" onkeydown="aotoCom()"/></td>
						<th class="tableleft">上级单位名称：</th>
						<td class="tableright"><input id="pCorpName2" type="text" class="textinput" maxlength="15" onkeyup="autoComByName()" onkeydown="autoComByName()"/></td>
					</tr>
					<tr>
					<th class="tableleft">单位地址：</th>
						<td class="tableright" colspan="5" style="padding-right: 77px;"><input id="address2" name="corp.address" type="text" class="textinput" value="${corp.address}" /></td>
					</tr>
					<tr>
						<th class="tableleft">邮政编码：</th>
						<td class="tableright"><input name="corp.postCode" id="postCode2" type="text" class="textinput" value="${corp.postCode}" /></td>
						<th class="tableleft">传真号码：</th>
						<td class="tableright"><input name="corp.faxNo" id="faxNo2" type="text" value="${corp.faxNo}" class="textinput" /></td>
						<th class="tableleft">Email：</th>
						<td class="tableright"><input name="corp.email" id="email2" type="text" value="${corp.email}" class="textinput"/></td>
					</tr>
					<tr>
						<th class="tableleft">经办人：</th>
						<td class="tableright">
							<input name="corp.contact" id="contact2" type="text" value="${corp.contact}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入联系人',invalidMessage:'请输入联系人'" />
						</td>
						<th class="tableleft">经办人证件号码：</th>
						<td class="tableright" colspan="3">
							<input name="corp.conCertNo" id="conCertNo" type="text" required="required" value="${corp.conCertNo}" class="textinput easyui-validatebox" />
							&nbsp;&nbsp;<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
						</td>
					</tr>
					<tr>
						<th class="tableleft">经办人手机号码：</th>
						<td class="tableright">
							<input name="corp.conPhone" id="conPhone2" type="text" value="${corp.conPhone}" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入联系人手机号码',invalidMessage:'请输入联系人手机号码'" />
						</td>
						<th class="tableleft">单位负责人：</th>
						<td class="tableright"><input name="corp.ceoName" id="ceoName2" type="text" value="${corp.ceoName}" class="textinput"/></td>
						<th class="tableleft">负责人手机号码：</th>
						<td class="tableright"><input name="corp.ceoPhone" id="ceohone2" type="text" value="${corp.ceoPhone}" class="textinput" /></td>
					</tr>
					<tr>
			 	 		<td colspan="6"><h3 class="subtitle">单位法人信息</h3></td>
			 		</tr>
					<tr>
						<th class="tableleft">法人：</th>
						<td class="tableright"><input name="corp.legName"
							id="legName2" type="text" value="${corp.legName}" class="textinput"/></td>
						<th class="tableleft">法人证件类型：</th>
						<td class="tableright"><input id="certType2" type="text"
							value="${corp.certType}" class="textinput" /></td>
						<th class="tableleft">法人证件号码：</th>
						<td class="tableright"><input name="corp.certNo" id="certNo2"
							type="text" value="${corp.certNo}" class="textinput" onkeydown="addCertNo()" onkeyup="addCertNo()" /></td>
					</tr>
					<tr>
						<th class="tableleft">法人联系电话：</th>
						<td class="tableright"><input name="corp.legPhone"
							id="legPhone2" type="text" value="${corp.legPhone}"
							class="textinput" /></td>
					</tr>
					<tr>
			 	 		<td colspan="6"><h3 class="subtitle">单位其他信息</h3></td>
			 		</tr>
					<!-- <tr>
						<th class="tableleft">所属省份：</th>
						<td class="tableright"><input name="corp.provCode"
							id="provCode2" type="text" value="${corp.provCode}"
							class="textinput" /></td>
						<th class="tableleft">所属城市：</th>
						<td class="tableright"><input name="corp.cityCode"
							id="cityCode2" type="text" value="${corp.cityCode}"
							class="textinput" /></td>
						<th class="tableleft">所在城区：</th>
						<td class="tableright"><input name="corp.regionId"
							id="regionId2" type="text" value="${corp.regionId}"
							class="textinput" /></td>
					</tr>-->
					<tr>
						<th class="tableleft">所属区域：</th>
						<td class="tableright"><input
							id="regionId2" type="text" value="${corp.regionId}"
							class="textinput" /></td>
						<th class="tableleft">社保单位编号：</th>
						<td class="tableright"><input name="corp.companyid"
							id="companyid2" type="text" value="${corp.companyid}"
							class="textinput" /></td>
						<th class="tableleft">是否车改：</th>
						<td class="tableright"><input name="corp.carrefFlag"
							id="carrefFlag2" type="text" value="${corp.carrefFlag}"
							class="textinput" /></td>
					</tr>
					<tr>
						<th class="tableleft">备注：</th>
						<td class="tableright" colspan="5">
							<textarea class="textinput" id="note2" name="corp.note"  style="width:969px;height:60px;overflow:hidden;">${corp.note}</textarea>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
</div>