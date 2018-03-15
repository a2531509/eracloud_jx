<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
 <head>
<base href="<%=basePath%>">
<title>身份证申领</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript" src="js/jquery-ui.js"></script>
<script type='text/javascript' src='dwr/interface/imgDeal.js'></script>
<style>
	.tablegrid th{font-weight:700};
</style>
	<script type="text/javascript">
	$(function(){
		if("${bustype3}" != ""){
			var tempchg = "[" + "${bustype3}" + "]";
			tempchg = eval('(' + tempchg +  ')');
			$("#bustype").combobox({
				width:174,
				data:tempchg,
				valueField:'codeValue',
				editable:false,
				value:'01',
			    textField:'codeName',
			    panelHeight:'auto',
			});
		}
		createLocalDataSelect({id:"costFeesId",data:[{value:'${costFees}',text:'${costFees}'}],});
		$('#costFeesId').combobox('setValue',${costFees});
		createLocalDataSelect({id:"urgentFeesId",data:[{value:'${urgentFees}',text:'${urgentFees}'}],});
		$('#urgentFeesId').combobox('setValue',${urgentFees});


 		 //性别
		createSysCode({id:"gender",codeType:"SEX"});
		//证件类型
		createSysCode({id:"certType2",codeType:"CERT_TYPE"});
		 $("#certType2").combobox("setValue","1");

		//民族
		createSysCode({id:"nation",codeType:"NATION"});
		//代理人证件类型
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
		//制卡方式
		createLocalDataSelect({id:"isUrgent",data:[{value:"0",text:"本地制卡"}],});
		$('#isUrgent').combobox('setValue','0');

		if("${defaultErrorMasg}" != ''){
			$.messager.alert("系统消息","${defaultErrorMasg}","error");
		}
		//客户状态
		createLocalDataSelect({id:"customerState",data:[{value:"",text:"请选择"},{value:"0",text:"正常"},{value:"1",text:"注销"}]});
		$('#customerState').combobox('setValue','0');
		
		getSearchInputData('bankId2','Base_Bank','bank_id','bank_name','');

		//是否确认
		createLocalDataSelect({id:"sureFlag",data:[{value:"",text:"请选择"},{value:"0",text:"是"},{value:"1",text:"否"}]});
		$('#sureFlag').combobox('setValue','0');

		//教育
		createSysCode({id:"education",codeType:"EDUCATION"});

		//婚姻状态
		createSysCode({id:"marrState",codeType:"MARR_STATE"});

		//户籍类型
		createLocalDataSelect({id:"resideType",data:[{value:"",text:"请选择"},{value:"0",text:"本地"},{value:"1",text:"外地"}]});
		$('#resideType').combobox('setValue','0');

		//所属区域
		createRegionSelect({id:"regionId"},{id:"townId"},{id:"commId"});

	});
	
	function readIdCard(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["name"]) == ""){
			return;
		}else{
			$("#certNo2").val(certinfo["cert_No"]);
			$("#name2").val(certinfo["name"]);
			commonDwr.getPinYin($("#name2").val(),function(data){
				if(dealNull(data).length >= 0){
					$("#pinyin").val(data);
				}
			});
			$('#gender').combobox('setValue', certinfo["sex"]);
			if(certinfo["nation"] == "汉"){
				$('#nation').combobox('setValue', '01');
			}
			$("#resideAddr").val(certinfo["address"]);
			
       		var aDate = new Date();   
       		var thisYear = aDate.getFullYear();
       		var thismonth = aDate.getMonth()+1;
       		var thisday = aDate.getDate();
       		if(thisday<10){thisday = "0"+ thisday};
       		var bDate = ""+thisYear+thismonth+thisday;
       		var brith = $("#certNo2").val().substr(6,8);
       		var by = $("#certNo2").val().substr(6,4);
       		var bm = $("#certNo2").val().substr(10,2);
       		var bd = $("#certNo2").val().substr(12,2);
       		var age = bDate-brith;
				if(age<180000){
					$("#bustype").combobox("setValue", "10");
				}else if(180000<age && age<590000){
					$("#bustype").combobox("setValue", "01");
		     	}else if(590000<age && age<690000){
					$("#bustype").combobox("setValue", "11");
				}else if(690000<age && age<2000000){
					$("#bustype").combobox("setValue", "20");
				}
			$('#birthday').val(by+'-'+bm+'-'+bd);
	  		imgDeal.getImgMessageByCard(certinfo["photo"],function(data){
    	  		dwr.util.setValue('imgPhoto',data.imageMsg);
    	  	});
	  		$("#personPhotoContent").val(certinfo["photo"]);
		}
	}
	
	function toSaveInfo(){

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
		if(dealNull($("#certNo2").val()).length != 18){
			$.messager.alert("系统消息","输入证件号码不正确！","error",function(){
				$("#certNo2").focus();
			});
			return;
		}
		if(dealNull($('#birthday').val()) == ""){
			$.messager.alert("系统消息","请输入客户出生年月！","error",function(){
			});
			return;
		}
		if(dealNull($("#gender").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择客户性别！","error",function(){
				$("#gender").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#nation").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择客户所属民族！","error",function(){
				$("#nation").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#customerState").combobox("getValue")) != "0"){
			$.messager.alert("系统消息","请确认用户状态！","error",function(){
				$("#customerState").combobox("showPanel");
			});
			return;
		}
		//社区判断
		if(dealNull($("#regionId").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择客户所属区域！","error",function(){
				$("#regionId").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#townId").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择客户所属村/镇！","error",function(){
				$("#townId").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#commId").combobox("getValue")) == ""){
			$.messager.alert("系统消息","请选择客户所属社区/街道！","error",function(){
				$("#commId").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#sureFlag").combobox("getValue")) != "0"){
			$.messager.alert("系统消息","请确认！","error",function(){
				$("#sureFlag").combobox("showPanel");
			});
			return;
		}

		var certNo2=$('#certNo2').val();
		if(dealNull(certNo2) == ''){
			$.messager.alert('系统消息','证件号码不能为空,请先进行查询再进行申领！','error');
			return;
		}

		if(dealNull($("#bustype").combobox("getValue")) == ""){
			$.messager.alert('系统消息','请选择公交类型!','error');
			return;
		}

		
		$.messager.confirm("系统消息","您确定要确认申领吗？",function(r){
			 if(r){
				 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				 $.post("cardapply/cardApplyAction!saveIdCardApply.action",
					 $("#form").serialize(),
					 function(data){
						 $.messager.progress('close');
				     	if(data.status == '0'){
				     		showReport('身份证申领',data.dealNo);
				     		$dg.datagrid('reload');
				     	}else{
				     		$.messager.alert('系统消息',data.msg,'error');
				     	}
				 },"json");
			 }
		});
	}
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>没有申领及已销卡人员进行个人申领，<span style="color:red;">特别提醒：</span>申领保存时，请根据实际情况选择公交类型。</strong></span></span>
		</div>
     </div>
     
	<div data-options="region:'center',border:true,title:'个人身份证申领'" style="overflow:auto;padding:0px;" class="datagrid-toolbar">
		<form id="form" method="post">
			<div id="tb" style="padding:2px 0,width:100%">
		 		 <table title="人员申领信息" style="width:100%" class="datagrid-toolbar"></table>
				 <table class="tablegrid" style="width:100%">
					 <tr>
					    <th class="tableleft" style="width:10%">姓名：</th>
						<td class="tableright"><input name="bp.name" id="name2" class="textinput easyui-validatebox" type="text"  required="required" onkeyup="getPinYin()" maxlength="32"/></td>
						<th class="tableleft">证件号码：</th>
						<td class="tableright"><input name="bp.certNo"  class="textinput easyui-validatebox" id="certNo2" type="text" validtype="idcard" required="required"/></td>
						<th class="tableleft">证件类型：</th>
						<td class="tableright"><input name="bp.certType" id="certType2" type="text" class="textinput  easyui-validatebox" validType="selectValueRequired['#certType']" /></td>
						<td  rowspan="4">
						<img id="imgPhoto" style="width:120px;height:160px;" src="images/defaultperson.gif" alt="个人照片"/>
						</td>
					 </tr>
					 <tr>
					 	<th class="tableleft">姓名拼音：</th>
						<td class="tableright" colspan="1"><input class="textinput" id="pinyin" name="bp.pinying" maxlength="100"/></td>
					    <th class="tableleft">生日：</th>
						<td class="tableright"><input name="bp.birthday" id="birthday"  type="text" class="Wdate textinput" maxlength="8"  validtype="date" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})"/></td>
						<th class="tableleft">性别：</th>
						<td class="tableright"><input id="gender" name="bp.gender" type="text" class="textinput"/></td>
					 </tr>
					 <tr>
					 	<th class="tableleft">民族：</th>
						<td class="tableright"><input id="nation" type="text" class="textinput easyui-validatebox" name="bp.nation"/></td>
					 	<th class="tableleft">文化程度：</th>
					 	<td class="tableright">
					 		<input id="education" class="textinput easyui-validatebox" name="bp.education"/>
						</td>
						<th class="tableleft">婚姻状况：</th>
					    <td class="tableright"><input id="marrState" class="textinput easyui-validatebox" name="bp.marrState" /></td>
					 </tr>
					 <tr>
					 	<th class="tableleft">户籍类型：</th>
						<td class="tableright"><input id="resideType" name="bp.resideType" class="textinput easyui-validatebox" /></td>
						<th class="tableleft">固定电话：</th>
						<td class="tableright"><input id="phoneNo" name="bp.phoneNo" type="text" class="textinput easyui-validatebox" validtype="phone" maxlength="22"/></td>
						<th class="tableleft">手机号码：</th>
						<td class="tableright"><input id="mobileNo" name="bp.mobileNo" type="text" class="textinput easyui-validatebox" validtype="mobile" maxlength="11"/></td> 
					 </tr>
					 <tr>
					    <th class="tableleft">所属区域：</th>
						<td class="tableright"><input name="bp.regionId" class="textinput" id="regionId" type="text"/></td>
						<th class="tableleft">乡镇（街道）：</th>
						<td class="tableright"><input name="bp.townId" class="textinput" id="townId" type="text"/></td>
						<th class="tableleft">社区（村）：</th>
						<td class="tableright"colspan="2"><input name="bp.commId" class="textinput" id="commId" type="text"/></td>
					 </tr>
					<tr>
						<th class="tableleft">职业：</th>
						<td class="tableright"><input id="career" name="bp.career" type="text" class="textinput" maxlength="20"/></td>
						<th class="tableleft">单位编号：</th>
						<td class="tableright"><input id="corpCustomerId" name="bp.corpCustomerId" type="text" class="textinput" maxlength="15"/></td>
						<!-- <th class="tableleft">数据来源：</th>
						<td class="tableright"><input id="dataSrc" class="textinput easyui-validatebox" name="bp.dataSrc"/></td> -->
						<th class="tableleft">客户状态：</th>
						<td class="tableright" colspan="2"><input class="textinput" id="customerState" name="bp.customerState"/></td>
					</tr>
					<tr>
						<th class="tableleft">邮箱：</th>
						<td class="tableright"><input id="email" name="bp.email" type="text" class="textinput easyui-validatebox" validtype="email" maxlength="32"/></td>
						<th class="tableleft">邮政编码：</th>
						<td class="tableright" colspan="1"><input class="textinput" id="postCode" name="bp.postCode" maxlength="6"/></td>
						<th class="tableleft">是否确认：</th>
						<td class="tableright" colspan="2"><input class="textinput" id="sureFlag" name="bp.sureFlag"/></td>
					</tr>
					<tr>
						<th class="tableleft">居住地址：</th>
						<td class="tableright" colspan="6"><input class="textinput" style="width:885px;" id="resideAddr" name="bp.resideAddr" maxlength="200"/></td>
					</tr>
					<tr>
						<th class="tableleft">联系地址：</th>
						<td class="tableright" colspan="6"><input class="textinput" style="width:885px;" id="letterAddr" name="bp.letterAddr" maxlength="200"/></td>
					</tr>
					<tr>
						<th class="tableleft" style="width:10%">公交类型：</th>
						<td class="tableright" style="width:19%"><input name="apply.busType" class="textinput"  id="bustype"  type="text" disabled="true"/></td>
						<th class="tableleft" style="width:10%">银行名称：</th>
						<td class="tableright" style="width:19%"><input name="apply.bankId" class="textinput easyui-validatebox" id="bankId2" class="easyui-combobox" validType="selectValueRequired['#bankId2']"  type="text"/></td>
						<th class="tableleft" style="width:10%">制卡方式：</th>
						<td class="tableright" style="width:19%" colspan="2"><input name="apply.isUrgent" class="textinput" id="isUrgent" type="textinput"  editable="false"/></td>
		
					</tr>
					<tr>
					    <th class="tableleft">工本费：</th>
					    <td class="tableright" ><input name="apply.costFee" class="textinput" id="costFeesId" type="text"/>   </td>
						<th class="tableleft">加急费：</th>
						<td class="tableright" ><input name="apply.urgentFee" class="textinput" id="urgentFeesId" type="text"/></td>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright" colspan="2" ><input name="apply.agtCertType" class="textinput" id="agtCertType" type="text"/></td>
					</tr>
					<tr>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright" ><input name="apply.agtCertNo" class="textinput easyui-validatebox" id="agtCertNo2" type="text" maxlength="18" validtype="idcard"/></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright" ><input name="apply.agtName" class="textinput" id="agtName2"   type="text" maxlength="30"/></td>
						<th class="tableleft">代理人联系电话：</th>
						<td class="tableright"  colspan="2"><input name="apply.agtPhone" class="textinput easyui-validatebox" id="agtTelNo2"  type="text"  maxlength="11" validtype="mobile"/></td>
					</tr>
					<tr>					
					<th class="tableleft">备注：</th>
					<td class="tableright" colspan="7"><textarea class="textinput" id="note" name="bp.note" maxlength="200" style="width:885px;overflow:hidden;">${bp.note}</textarea></td>
				    </tr>
				     <tr>
						<td colspan="7" align="center" class="tableQueryButton">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toSaveInfo();" >申领保存</a>
						 <input name = "personPhotoContent" id ="personPhotoContent" style="visibility:hidden">
						</td>
						<shiro:hasPermission name="busTypeChange">
							<script type="text/javascript">
								  $('#bustype').combobox({ 
								   	disabled: false,
								 });
							</script>
						</shiro:hasPermission>						
					</tr>
				 </table>
			</div>
		</form>
	</div>
</body>
</html>
