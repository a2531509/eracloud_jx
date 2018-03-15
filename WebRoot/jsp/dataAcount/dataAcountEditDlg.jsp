<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<style>
	.tablegrid th{font-weight:700}
</style>
<script type="text/javascript">
var isFirstLoad = true;
$(function(){
	$.autoComplete({
		id:"corpCustomerId2",
		text:"customer_id",
		value:"corp_name",
		table:"base_corp",
		keyColumn:"customer_id",
		minLength:"1"
	},"corpCustomerName2");
	$.autoComplete({
		id:"corpCustomerName2",
		text:"corp_name",
		value:"customer_id",
		table:"base_corp",
		keyColumn:"corp_name",
		minLength:"1"
	},"corpCustomerId2");

	
	isFirstLoad = true;
	$.addIdCardReg("certNo2");
	if("${defaultErrorMasg}" != ''){
		$.messager.alert("系统消息","${defaultErrorMasg}","error");
	}
	createSysCode({
		id:"nation",
		codeType:"NATION",
		isShowDefaultOption:false
	});
	$("#customerState").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"0",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'0',codeName:"正常"},{codeValue:'1',codeName:"注销"}]
	});
	if("${queryType}" == "0"){
		$("#customerState").combobox("disable");
	}
	$("#sureFlag").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
		value:"0",
	    textField:"codeName",
	    panelHeight:'auto',
	    data:[{codeValue:'0',codeName:"是"},{codeValue:'1',codeName:"否"}]
	});
	if("${queryType}" == "0"){
		$("#sureFlag").combobox("disable");
	}
	createSysCode({
		id:"education",
		codeType:"EDUCATION",
		isShowDefaultOption:false,
		loadFilter:function(data){
			var recs = data.rows;
			return recs.reverse();
		}
	});
	createSysCode({
		id:"gender",
		codeType:"SEX",
		isShowDefaultOption:false
	});
	createSysCode({
		id:"certType2",
		codeType:"CERT_TYPE",
		isShowDefaultOption:false,
		onSelect:function(row){
			if(row.VALUE == "<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"){
				$.addIdCardReg("certNo2");
				$("#certNo2").validatebox("enableValidation");
			}else{
				$("#certNo2").get(0).onkeydown = undefined;
				$("#certNo2").get(0).onkeyup = undefined;
				$("#certNo2").validatebox("disableValidation");
			}
		}
	});
	//$("#certType2").combobox("setValue","1");
	//婚姻状态
	createSysCode({
		id:"marrState",
		codeType:"MARR_STATE"
	});
	//户籍类型
	$("#resideType").combobox({
		width:174,
		valueField:'codeValue',
		editable:false,
	    textField:"codeName",
	    panelHeight:'auto',
	    value:"0",
	    data:[{codeValue:'0',codeName:"本地"},{codeValue:'1',codeName:"外地"}]
	});
	//所属区域
    $("#regionId").combobox({ 
	    url:"commAction!getAllRegion.action",
	    editable:false,
	    cache:false,
	    width:174,
	    valueField:'region_Id',   
	    textField:'region_Name',
    	onSelect:function(node){
    		$("#townId").combobox('clear');
    		$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + node.region_Id);
    	},
    	onLoadSuccess:function(){
	 		var cys = $("#regionId").combobox('getData');
	 		if(cys.length > 0){
	 			if("${bp.regionId}" != "" && isFirstLoad){
	 				$("#regionId").combobox("setValue","${bp.regionId}");
	 				tempreginId = "${bp.regionId}";
	 			}else{
		 			$(this).combobox('setValue',cys[0].region_Id);
		 			tempreginId = cys[0].region_Id;
	 			}
	 			$("#townId").combobox('clear');
	 			$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + tempreginId);
	 		}
	    }
	 }); 
	//乡镇(街道)
	 $("#townId").combobox({ 
	    editable:false,
	    cache: false,
	    width:174,
	    //panelHeight:'auto',
	    valueField:'town_Id',   
	    textField:'town_Name',
	    onSelect:function(node){
    		$("#commId").combobox('clear');
    		$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + node.town_Id);
    	},
    	onLoadSuccess:function(){
	 		var cys = $("#townId").combobox('getData');
	 		if(cys.length > 0){
	 			var temptownId = "";
	 			if("${bp.townId}" != "" && isFirstLoad){
	 				$("#townId").combobox("setValue","${bp.townId}");
	 				temptownId = "${bp.townId}";
	 			}else{
	 				$(this).combobox('setValue',cys[0].town_Id);
	 				temptownId = cys[0].town_Id;
	 			}
	 			$("#commId").combobox('clear');
	 			$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + temptownId);
	 		}
	    }
	 });
	//社区(村)
	 $("#commId").combobox({ 
	    editable:false,
	    cache: false,
	    width:174,
	    valueField:'comm_Id',   
	    textField:'comm_Name',
	    onLoadSuccess:function(){
	 		var cys = $("#commId").combobox('getData');
	 		if(cys.length > 0){
	 			if("${bp.commId}" != "" && isFirstLoad){
	 				$("#commId").combobox("setValue","${bp.commId}");
	 				isFirstLoad = false;
	 			}else{
	 				$(this).combobox('setValue',cys[0].comm_Id);
	 				isFirstLoad = false;
	 			}
	 		}
	    }
	 });
	 //内容初始化
	 if("${bp.gender}" != ""){
		 $("#gender").combobox("setValue","${bp.gender}");
	 }else{
		 $("#gender").combobox("setValue",'1');
	 }
	 if("${bp.nation}" != ""){
		 $("#nation").combobox("setValue","${bp.nation}");
	 }
	 if("${bp.education}" != ""){
		 $("#education").combobox("setValue","${bp.education}");
	 }
	 if("${bp.marrState}" != ""){
		 $("#marrState").combobox("setValue","${bp.marrState}");
	 }
	 if("${bp.resideType}" != ""){
		 $("#resideType").combobox("setValue","${bp.resideType}");
	 }
	 if("${bp.customerState}" != ""){
		 $("#customerState").combobox("setValue","${bp.customerState}");
	 }
	 if("${bp.sureFlag}" != ""){
		 $("#sureFlag").combobox("setValue","${bp.sureFlag}");
	 }
	 if("${bp.certType}" != ""){
		 $("#certType2").combobox("setValue","${bp.certType}");
	 }else{
		 $("#certType2").combobox("setValue",'<s:property value="@com.erp.util.Constants@CERT_TYPE_SFZ"/>');
	 }
});
//新增或是编辑保存
function saveAddOrUpdateBasePersonal(){
	var subtitle = "";
	if($("#queryType").val() == "0"){
		subtitle = "新增";
	}else if($("#queryType").val() == "1"){
		subtitle = "编辑";
	}else{
		$.messager.alert("系统消息","获取操作类型错误！","error");
		return;
	}
	if(dealNull($("#name2").val()) == ""){
		$.messager.alert("系统消息","请输入客户姓名！","error",function(){
			$("#name2").focus();
		});
		return;
	}
	if(dealNull($("#certType2").combobox("getValue")) == ""){
		$.messager.alert("系统消息","请选择客户证件类型！","error",function(){
			$("#certType2").combobox("showPanel");
		});
		return;
	}
	if(dealNull($("#certNo2").val()) == ""){
		$.messager.alert("系统消息","请输入客户证件号码！","error",function(){
			$("#certNo2").focus();
		});
		return;
	}
	if(dealNull($("#certNo2").val()).length != 18 && $("#certType2").combobox("getValue") == "1"){
		$.messager.alert("系统消息","输入证件号码不正确！","error",function(){
			$("#certNo2").focus();
		});
		return;
	}
	if(dealNull($("#phoneNo").val()) == "" && dealNull($("#mobileNo1").val()) == ""){
		$.messager.alert("系统消息","固定电话或手机号码不能为空！","error",function(){
			$("#phoneNo").focus();
		});
		return;
	}
	$.messager.confirm("系统消息","您确定要" + subtitle + "人员基本信息吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("dataAcount/dataAcountAction!toSaveAddOrUpdateBasePersonal.action",$("#form").serialize(),function(data,status){
				 $.messager.progress('close');
				 if(status == "success"){
					 $.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						 if(data.status == "0"){
							 $dg.datagrid("reload");
							 $.modalDialog.handler.dialog('destroy');
							 $.modalDialog.handler = undefined;
						 }
					 });
				 }else{
					 $.messager.alert("系统消息",subtitle + "人员基本信息出现错误，请重新进行操作！","error");
					 return;
				 }
			 },"json");
		 }
	});
}
function getPinYin(){
	commonDwr.getPinYin($("#name2").val(),function(data){
		if(dealNull(data).length >= 0){
			$("#pinyin").val(data);
		}
	});
}

function calulate(){
	if($("#certNo2").val().length == 18 && event.keyCode == 13 && $("#certType2").combobox("getValue") == "<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"){
		getPinYin();
		if($("#certNo2").val().charAt(16)){
			if($("#certNo2").val().charAt(16)%2 == 0){
				$("#gender").combobox("setValue","2");
			}else{
				$("#gender").combobox("setValue","1");
			}
		}
		$("#birthday").val($("#certNo2").val().substring(6,10) + "-" + $("#certNo2").val().substring(10,12) + "-" + $("#certNo2").val().substring(12,14));
		 $("#certType2").combobox("setValue",'<s:property value="@com.erp.util.Constants@CERT_TYPE_SFZ"/>');
	}
}

function autoCompletePersonInfo(){
	var certType = $("#certType2").combobox("getValue");
	
	if(certType != "<%=Constants.CERT_TYPE_SFZ%>"){
		return;
	}
	
	var certNo = $("#certNo2").val();
	
	if(!certNo){
		return;
	}
	
	
	var birthday = "";
	var gender = "";
	
	if(certNo.length == 15){
		
	} else if(certNo.length == 18){
		birthday = certNo.substring(6, 10) + "-" + certNo.substring(10, 12) + "-" + certNo.substring(12, 14);
		gender = parseInt(certNo.substring(16, 17)) % 2;
	}
	
	$("#gender").combobox("setValue", gender == 0 ? 2 : 1);
	$("#birthday").val(birthday);
}
function readIdCard2(){
	$.messager.progress({text:"正在获取证件信息，请稍后...."});
	var o = getcertinfo();
	if(dealNull(o["name"]).length == 0){
		$.messager.progress("close");
		return;
	}
	$.messager.progress("close");
	$("#certNo2").val(o["cert_No"]);
}

//addNumberValidById("certNo2");
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" style="overflow:hidden;padding:0px;" class="datagrid-toolbar">
		<form id="form" method="post">		
			 <s:hidden name="bp.customerId" id="customerId"></s:hidden>
			 <s:hidden name="queryType" id="queryType"></s:hidden>
			 <table class="tablegrid" style="width:100%">
				 <tr>
				    <th class="tableleft" style="width:10%">姓名：</th>
					<td class="tableright"><input name="bp.name" id="name2" class="textinput easyui-validatebox" type="text" value="${bp.name}" required="required" onkeyup="getPinYin()" maxlength="30"/></td>
					<th class="tableleft">证件类型：</th>
					<td class="tableright"><input name="bp.certType" id="certType2" type="text" class="textinput" required="required"/></td>
					<th class="tableleft">证件号码：</th>
					<td class="tableright">
						<input name="bp.certNo"  class="textinput easyui-validatebox" id="certNo2" type="text" validtype="idcard" value="${bp.certNo}" required="required" onkeypress="calulate()" maxlength="18" onchange="autoCompletePersonInfo()" onkeyup="autoCompletePersonInfo()"/>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
					</td>
				 </tr>
				 <tr>
				 	<th class="tableleft">姓名拼音：</th>
					<td class="tableright"><input name="bp.pinying" class="textinput" id="pinyin" value="${bp.pinying}" onclick="getPinYin()" maxlength="100"/></td>
					<th class="tableleft">性别：</th>
					<td class="tableright"><input name="bp.gender" id="gender" type="text" class="textinput"/></td>
					<th class="tableleft">民族：</th>
					<td class="tableright"><input name="bp.nation" id="nation" type="text" class="textinput"/></td>
				 </tr>
				 <tr>
				 	<th class="tableleft">户籍类型：</th>
					<td class="tableright"><input name="bp.resideType" id="resideType" class="textinput" /></td>
				 	<th class="tableleft">出生日期：</th>
					<td class="tableright"><input name="bp.birthday" id="birthday" type="text" class="Wdate textinput" maxlength="8" value="${bp.birthday}" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})"/></td>
					<th class="tableleft">文化程度：</th>
				 	<td class="tableright"><input id="education" class="textinput" name="bp.education"/></td>
				 	
				 </tr>
				 <tr>
				    <th class="tableleft">所属区域：</th>
					<td class="tableright"><input name="bp.regionId" class="textinput" id="regionId" type="text"/></td>
					<th class="tableleft">乡镇（街道）：</th>
					<td class="tableright"><input name="bp.townId" class="textinput" id="townId" type="text"/></td>
					<th class="tableleft">社区（村）：</th>
					<td class="tableright"><input name="bp.commId" class="textinput" id="commId" type="text"/></td>
				 </tr>
				 <tr>
				 	<th class="tableleft">客户状态：</th>
					<td class="tableright"><input name="bp.customerState" class="textinput" id="customerState"/></td>
					<th class="tableleft">确认标志：</th>
					<td class="tableright"><input name="bp.sureFlag" class="textinput" id="sureFlag" value="${bp.sureFlag}"/></td>
					<th class="tableleft">电子邮件：</th>
					<td class="tableright"><input name="bp.email" id="email" type="text" value="${bp.email}" class="textinput" maxlength="32"/></td>
				 </tr>
				<tr>
					<th class="tableleft">邮政编码：</th>
					<td class="tableright"><input name="bp.postCode" class="textinput" id="postCode" maxlength="6" value="${bp.postCode}"/></td>
					<th class="tableleft">固定电话1：</th>
					<td class="tableright"><input id="phoneNo" name="bp.phoneNo" value="${bp.phoneNo}" type="text" class="textinput easyui-validatebox" required="required" validtype="phone" maxlength="22"/></td>
					<th class="tableleft">固定电话2：</th>
					<td class="tableright"><input id="telNos" name="bp.telNos" value="${bp.telNos}" type="text" class="textinput" maxlength="22"/></td>
				</tr>
				<tr>
					<th class="tableleft">手机号码1：</th>
					<td class="tableright"><input id="mobileNo1" name="bp.mobileNo" value="${bp.mobileNo}" type="text" class="textinput" maxlength="11"/></td>
					<th class="tableleft">手机号码2：</th>
					<td class="tableright"><input id="mobileNos" name="bp.mobileNos" value="${bp.mobileNos}" type="text" class="textinput" maxlength="11"/></td>  
					<th class="tableleft">婚姻状况：</th>
				    <td class="tableright"><input name="bp.marrState" id="marrState" class="textinput" /></td>
				</tr>
				<tr>
				    <th class="tableleft">职业：</th>
					<td class="tableright"><input name="bp.career" id="career" type="text" value="${bp.career}" class="textinput" maxlength="20"/></td>
					<th class="tableleft">单位编号：</th>
					<td class="tableright">
						<input name="bp.corpCustomerId" id="corpCustomerId2" value="${bp.corpCustomerId}" type="text" class="textinput"/>
					</td>
					<th class="tableleft">单位名称：</th>
					<td class="tableright">
						<input name="corpName" id="corpCustomerName2" value="${corpName}" type="text" class="textinput"/>
					</td>
				</tr>
				<tr>
					<th class="tableleft">居住地址：</th>
					<td class="tableright" colspan="6"><input name="bp.resideAddr" class="textinput" style="width:925px;" id="resideAddr" value="${bp.resideAddr}" maxlength="200"/></td>
				</tr>
				<tr>
					<th class="tableleft">联系地址：</th>
					<td class="tableright" colspan="6"><input name="bp.letterAddr" class="textinput" style="width:925px;" id="letterAddr" value="${bp.letterAddr}" maxlength="200"/></td>
				</tr>
				<tr>
					<th class="tableleft">备注：</th>
					<td class="tableright" colspan="6"><textarea name="bp.note" class="textinput" id="note" maxlength="200" style="width:925px;height:60px;overflow:hidden;">${bp.note}</textarea></td>
				</tr>
			 </table>
		</form>
	</div>
</div>