<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<style>
input::-ms-clear{display:none;}
</style>
<script type="text/javascript">
	function setValue(vTxt) {
	    $('#topMerchantId').combobox('setValue', vTxt);
	 }
	function checkEndTime(){  
	    var startTime=$("#validDate").val();  
	    var start=new Date(startTime.replace("-", "/").replace("-", "/"));  
	    var endTime=timeStamp2String(new Date());  
	    var end=new Date(endTime.replace("-", "/").replace("-", "/"));  
	    if(start<=end){  
	        return false;  
	    }  
	    return true;  
	}  
	
	function timeStamp2String(time){
		var datetime = new Date();     
		datetime.setTime(time);     
		var year = datetime.getFullYear();     
		var month = datetime.getMonth() + 1 < 10 ? "0" + (datetime.getMonth() + 1) : datetime.getMonth() + 1;     
		var date = datetime.getDate() < 10 ? "0" + datetime.getDate() : datetime.getDate();     
		return year + "-" + month + "-" + date; 
	} 
	$(function() {
		createCustomSelect({
			id:"region",
			value:"region_id",
			text:"region_name",
			table:"base_region",
			orderby:"region_id desc",
			from:1,
			to:20
		});

		$("#topMerchantId").combobox({
		   panelHeight:200,
		   panelMaxHeight:200,
		   url:"merchantRegister/merchantRegisterAction!findALLMerchant.action",
           valueField: 'merchantId', 
           textField: 'merchantName',
           //注册事件
           onChange: function (newValue, oldValue) {
               if (newValue != null) {
                   var thisKey = encodeURIComponent($('#topMerchantId').combobox('getText')); //搜索词
                   var urlStr = "merchantRegister/merchantRegisterAction!getBizName.action?objStr=" + thisKey;
                   var v = $("#topMerchantId").combobox("reload", urlStr);
               }
           },
           
        });
		createLocalDataSelect({
			id:"stlType",
			value:"0",
		    data:[
		        {value:"0",text:"自己结算"},
		        {value:"1",text:"上级结算"}
		    ]
		});
		createLocalDataSelect({
			id:"isSettleMonth",
			value:"",
		    data:[
				{value:"",text:"请选择"},
		        {value:"0",text:"月末强制结算"},
		        {value:"1",text:"月末不强制结算"}
		    ]
		});
		$("#orgId").combobox({
			width:174,
			url:"sysOrgan/sysOrganAction!findAllOrgan.action",
			valueField:'orgId', 
			editable:false, //不可编辑状态
		    textField:'orgName',
		    onSelect:function(node){
		 		$("#orgId").val(node.text);
		 	}
		});
		
		
		$("#bankId").combobox({
			width:174,
			url:"commAction!getAllBanks.action",
			valueField:'bank_id', 
			panelHeight:200,
			panelMaxHeight:200,
			editable:false, //不可编辑状态
		    textField:'bank_name',
		    onSelect:function(node){
		 		$("#bankId").val(node.text);
		 	}
		});
		
		createSysCode("legCertType",{codeType:"CERT_TYPE",editable:false});
		
		//初始话下拉上级商户下拉框
		$("#merchantType").combotree({
			width:174,
			panelHeight:100,
			url:"merchantType/merchantTypeAction!findMerchantTypeListTreeGrid.action",
			idFiled:'id',
		 	textFiled:'typeName',
		 	parentField:'parentId'
		});
		//初始话下拉行业类型下拉框
		createSysCode("indusCode",{codeType:"INDUS_CODE",editable:true});
		createSysCode("stlMode",{codeType:"STL_MODE",editable:false});
		$("#stlWay").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=STL_WAY",
			valueField:'codeValue', 
			editable:false, //不可编辑状态
		    textField:'codeName',
		    loadFilter:function(data){
				if(data.status != "0"){
				}
				
				var rows = data.rows;
				rows.push({"codeName":"月结（七天结）","codeState":null,"codeType":"STL_WAY","codeValue":"05","ordNo":"5","typeName":"结算方式"});
				
				return rows;
			},
		    onSelect:function(node){
		 		$("#stlWay").val(node.text);
		 		if(node.codeValue=='02'){
		 			$("#styWay1_lmt_th").css("display","table-cell");
		 			$("#styWay1_lmt_td").css("display","table-cell");
		 			$("#styWay1_cicrl_th").css("display","none");
		 			$("#styWay1_cicrl_td").css("display","none");
		 		}else if(node.codeValue==''){
		 			$("#styWay1_lmt_th").css("display","none");
		 			$("#styWay1_lmt_td").css("display","none");
		 			$("#styWay1_cicrl_th").css("display","none");
		 			$("#styWay1_cicrl_td").css("display","none");
		 		}else{
		 			$("#styWay1_lmt_th").css("display","none");
		 			$("#styWay1_lmt_td").css("display","none");
		 			$("#styWay1_cicrl_th").css("display","table-cell");
		 			$("#styWay1_cicrl_td").css("display","table-cell");
		 		}
		 		
		 		if(node.codeValue=='05'){
		 			$("#stlDays").val("7|14|21|28|32");
		 		}
		 	}
		});
		$("#stlWayRet").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=STL_WAY",
			valueField:'codeValue', 
			editable:false, //不可编辑状态
		    textField:'codeName',
		    loadFilter:function(data){
				if(data.status != "0"){
				}
				return data.rows;
			},
		    onSelect:function(node){
		 		$("#stlWayRet").val(node.text);
		 		if(node.codeValue=='02'){
		 			$("#styWay2_lmt_th").css("display","table-cell");
		 			$("#styWay2_lmt_td").css("display","table-cell");
		 			$("#styWay2_cicrl_th").css("display","none");
		 			$("#styWay2_cicrl_td").css("display","none");
		 		}else if(node.codeValue==''){
		 			$("#styWay2_lmt_th").css("display","none");
		 			$("#styWay2_lmt_td").css("display","none");
		 			$("#styWay2_cicrl_th").css("display","none");
		 			$("#styWay2_cicrl_td").css("display","none");
		 		}else{
		 			$("#styWay2_lmt_th").css("display","none");
		 			$("#styWay2_lmt_td").css("display","none");
		 			$("#styWay2_cicrl_th").css("display","table-cell");
		 			$("#styWay2_cicrl_td").css("display","table-cell");
		 		}
		 	}
		});
		$("#stlWayFee").combobox({
			width:174,
			url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=STL_WAY",
			valueField:'codeValue', 
			editable:false, //不可编辑状态
		    textField:'codeName',
		    loadFilter:function(data){
				if(data.status != "0"){
				}
				return data.rows;
			},
		    onSelect:function(node){
		 		$("#stlWayFee").val(node.text);
		 		if(node.codeValue=='02'){
		 			$("#styWay3_lmt_th").css("display","table-cell");
		 			$("#styWay3_lmt_td").css("display","table-cell");
		 			$("#styWay3_cicrl_th").css("display","none");
		 			$("#styWay3_cicrl_td").css("display","none");
		 		}else if(node.codeValue==''){
		 			$("#styWay3_lmt_th").css("display","none");
		 			$("#styWay3_lmt_td").css("display","none");
		 			$("#styWay3_cicrl_th").css("display","none");
		 			$("#styWay3_cicrl_td").css("display","none");
		 		}else{
		 			$("#styWay3_lmt_th").css("display","none");
		 			$("#styWay3_lmt_td").css("display","none");
		 			$("#styWay3_cicrl_th").css("display","table-cell");
		 			$("#styWay3_cicrl_td").css("display","table-cell");
		 		}
		 	}
		});
		
		
		$("#form").form({
			url :"/merchantRegister/merchantRegisterAction!saveRegistMer.action",
			data: $('#form').serialize(),
			onSubmit : function() {
				if($("#merchantName").val()==""){
					$.messager.alert("系统消息","请输入商户名称","error",function(){
						$("#merchantName").focus();
					});
					return false;
				}
				if($("#stlType").combobox("getValue")==""){
					$.messager.alert("系统消息","【自己/上级结算】不能为空，请选择","error",function(){
						$("#stlType").combobox("showPanel");
					});
					return false;
				}
				if($("#merchantType").combobox("getValue")==""){
					$.messager.alert("系统消息","【商户类型】不能为空，请选择商户类型","error",function(){
						$("#merchantType").combobox("showPanel");
					});
					return false;
				}	
				
				if($("#orgId").combobox("getValue")==""){
					$.messager.alert("系统消息","【所属机构】不能为空，请选择","error",function(){
						$("#orgId").combobox("showPanel");
					});
					return false;
				}
				
				if($("#contact").val()==""){
					$.messager.alert("系统消息","【联系人姓名】不能为空，请输入","error",function(){
						$("#contact").focus();
					});
					return false;
				}
				
				if($("#conPhone").val()==""){
					$.messager.alert("系统消息","【联系人电话】不能为空，请输入","error",function(){
						$("#conPhone").focus();
					});
					return false;
				}
				if($("#indusCode").combobox("getValue")==""){
					$.messager.alert("系统消息","【行业类型】不能为空，请选择行业类型","error",function(){
						$("#indusCode").combobox("showPanel");
					});
					return false;
				}
				if($("#bankAccName").val()==""){
					$.messager.alert("系统消息","【银行账户名称】不能为空，请输入","error",function(){
						$("#bankAccName").focus();
					});
					return;
				}
				
				if($("#bankAccNo").val()==""){
					$.messager.alert("系统消息","【银行账号】不能为空，请输入","error",function(){
						$("#bankAccNo").focus();
					});
					return;
				}
				
				if($("#bankBrch").val()==""){
					$.messager.alert("系统消息","【开户银行】不能为空，请输入","error",function(){
						$("#bankBrch").focus();
					});
					return false;
				}
				
				if($("#address").val()==""){
					$.messager.alert("系统消息","【通讯地址】不能为空，请输入","error",function(){
						$("#address").focus();
					});
					return false;
				}
				
				if($("#stlMode").combobox('getValue')==''){
					$.messager.alert("系统消息","【结算模式】不能为空，请选择行结算模式","error",function(){
						$("#stlMode").combobox("showPanel");
					});
					return false;
				}
				if($("#stlWay").combobox('getValue')==''){
					$.messager.alert("系统消息","【结算方式】不能为空，请选择行结算方式","error",function(){
						$("#stlWay").combobox("showPanel");
					});
					return false;
				}else{
					if($("#stlWay").combobox('getValue')=='2'){
						if($("#stlLim").val()==''){
							$.messager.alert("系统消息","【结算限额参数】不能为空，请输入","error",function(){
								$("#stlLim").focus();
							});
							return false;
						}
					}else{
						if($("#stlDays").val()==''){
							$.messager.alert("系统消息","【结算周期参数】不能为空，请输入","error",function(){
								$("#stlDays").focus();
							});
							return false;
						}
					}
				}
				
				if($("#stlWayRet").combobox('getValue')==''){
					$.messager.alert("系统消息","【退货结算方式参数】不能为空，请输入","error",function(){
						$("#stlWayRet").combobox("showPanel");
					});
					return false;
				}else{
					if($("#stlWayRet").combobox('getValue')=='2'){
						if($("#stlLimRet").val()==''){
							$.messager.alert("系统消息","【退货结算限额参数】不能为空，请输入","error",function(){
								$("#stlLimRet").focus();
							});
							return false;
						}
					}else{
						if($("#stlDaysRet").val()==''){
							$.messager.alert("系统消息","【退货结算周期参数】不能为空，请输入","error",function(){
								$("#stlDaysRet").focus();
							});
							return false;
						}
					}
				}
				
				if($("#stlWayFee").combobox('getValue')==''){
					$.messager.alert("系统消息","【服务费结算方式】不能为空，请输入","error",function(){
						$("#stlWayFee").combobox("showPanel");
					});
					return false;
				}else{
					if($("#stlWayFee").combobox('getValue')=='2'){
						if($("#stlLimFee").val()==''){
							$.messager.alert("系统消息","【服务费结算限额参数】不能为空，请输入","error",function(){
								$("#stlLimFee").focus();
							});
							return false;
						}
					}else{
						if($("#stlDaysFee").val()==''){
							$.messager.alert("系统消息","【服务费结算周期参数】不能为空，请输入","error",function(){
								$("#stlDaysFee").focus();
							});
							return false;
						}
					}
				}
				if($("#validDate").val() == ""){
					$.messager.alert("系统消息","【生效日期】不能为空，请输入","error",function(){
						$("#validDate").focus();
					});
					return false;
				}
				
				$.messager.progress({
					title : '提示',
					text : '数据处理中，请稍后....'
				});
				return true;
				//验证输入框的值
			},
			success:function(result) {
				$.messager.progress('close');
				result = $.parseJSON(result);
				if (result.status) {
					 $.modalDialog.handler.dialog('destroy');
					 $.modalDialog.handler = undefined;
					 $.messager.alert("系统消息",result.message,"info");
					 $dg.datagrid("reload");
				}else{
					$.messager.show({
						title :  result.title,
						msg : result.message,
						timeout : 1000 * 2
					});
				}
			}
		});
		
	});
	
	
    function autoComByName(){
        if($("#topMerchantId").val() == ""){
            $("#topMerchantId").val("");
        }
        $("#topMerchantId").autocomplete({
            source:function(request,response){
                $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
                    response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
                },'json');
            },
            select: function(event,ui){
                $('#topMerchantId').val(ui.item.value);
                return false;
            },
            focus: function(event,ui){
                return false;
            }
        }); 
    }
  
</script>
<div class="easyui-layout" data-options="fit:true,border:false">
	<div data-options="region:'center',border:false" title="" style="overflow: scroll;padding: 10px;" class="datagrid-toolbar">
		<form id="form" method="post">
				 <input name="merchant.customerId" id="customerId"  type="hidden"/>
				 <table class="tablegrid" style="width: 100%">
				 	<tr>
			 	 		<td colspan="6"><h3 class="subtitle">商户基本信息</h3></td>
			 	 	</tr>	
					 <tr>
					    <th class="tableleft">商户名称</th>
						<td class="tableright"><input name="merchant.merchantName" id="merchantName" required="required" maxlength="128" class="textinput easyui-validatebox" type="text" /><span style="color:red;vertical-align: middle;"> * </span></td>
						<th class="tableleft">自己/上级结算</th>
						<td class="tableright">
							<input name="merchant.stlType"  id="stlType" class="textinput easyui-validatebox" data-options="panelHeight: 'auto',editable:false" required="required"  />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft">商户类型</th>
						<td class="tableright">
							<input name="merchant.merchantType"  class="textinput easyui-validatebox" id="merchantType"   data-options="panelHeight: '20px',editable:false" required="required"/>
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
					 </tr>
					 <tr>
						<th class="tableleft">所属机构</th>
						<td class="tableright">
							<input name="merchant.orgId" class="easyui-combobox easyui-validatebox" id="orgId" data-options="panelHeight: 'auto',editable:false"  style="width:174px;" required="required"/>
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft">工商注册号</th>
						<td class="tableright">
							<input name="merchant.bizRegNo" id="bizRegNo"  class="textinput" maxlength="32" type="text" />
							
						</td>
						<th class="tableleft">上级商户</th>
						<td class="tableright">
							<input name="merchant.topMerchantId"  class="textinput" id="topMerchantId" onkeydown="autoComByName()" onkeyup="autoComByName()" data-options="panelHeight: 'auto'" />
						</td>
					</tr>
					<tr>
					    <th class="tableleft">行业类型</th>
						<td class="tableright">
							<input name="merchant.indusCode" id="indusCode"   class="easyui-combobox easyui-validatebox" required="required" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft">合同号:</th>
						<td class="tableright">
							<input name="merchant.contactNo" id="contactNo" maxlength="100" class="textinput" type="text"/>
						</td>
						<th class="tableleft">合同类型:</th>
						<td class="tableright"><input name="merchant.contactType" id="contactType" maxlength="100" class="textinput" type="text"/>
						</td>
					</tr>
					<tr>
						<th class="tableleft">开户银行</th>
						<td class="tableright">
	                    	<input name="merchant.bankBrch" id="bankBrch"   maxlength="128" class="textinput easyui-validatebox" data-options="required:true" type="text" />
	                    	<span style="color:red;vertical-align: middle;"> * </span>
	                    </td>
						<th class="tableleft">银行账户名称</th>
						<td class="tableright">
							<input name="merchant.bankAccName" id="bankAccName"  required="required" maxlength="128"  class="textinput easyui-validatebox" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft">银行账户账号</th>
	                    <td class="tableright">
	                    	<input name="merchant.bankAccNo" id="bankAccNo"  maxlength="50" required="required" class="textinput easyui-validatebox" type="text" />
	                    	<span style="color:red;vertical-align: middle;"> * </span>
	                    </td>
					</tr>
					<tr>
						<th class="tableleft">联系人姓名</th>
						<td class="tableright">
							<input name="merchant.contact" id="contact"  class="textinput easyui-validatebox" maxlength="32" type="text" required="required"/>
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft">联系人证件号码</th>
						<td class="tableright"><input name="merchant.conCertNo" id="conCertNo" maxlength="36" class="textinput" type="text"/>
						</td>
						<th class="tableleft">联系人电话1</th>
						<td class="tableright">
							<input name="merchant.conPhone" id="conPhone"  class="textinput easyui-validatebox" maxlength="32" type="text" required="required"/>
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
					</tr>
					<tr>
						<th class="tableleft">联系人电话2</th>
						<td class="tableright"><input name="merchant.conPhone2" id="conPhone2"  class="textinput" maxlength="32" type="text"/>
						</td>
						<th class="tableleft">法人姓名</th>
						<td class="tableright"><input name="merchant.legName" id="legName"  maxlength="32" class="textinput" type="text" />
						</td>
						<th class="tableleft">法人证件类型</th>
						<td class="tableright"><input name="merchant.legCertType" id="legCertType"  class="easyui-combobox" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">法人证件号码</th>
						<td class="tableright"><input name="merchant.legCertNo" id="legCertNo"  maxlength="36" class="textinput" type="text" />
						</td>
						<th class="tableleft">法人手机号码</th>
						<td class="tableright"><input name="merchant.legPhone" id="legPhone"  maxlength="32" class="textinput" type="text" />
						</td>
						<th class="tableleft">Email</th>
						<td class="tableright">
							<input name="merchant.email" id="email"  maxlength="64" class="textinput easyui-validatebox" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">通讯地址</th>
						<td class="tableright">
							<input name="merchant.address" id="address"  maxlength="128" class="textinput easyui-validatebox" data-options="required:true" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft">邮政编码</th>
						<td class="tableright"><input name="merchant.postCode" id="postCode"  maxlength="6" class="textinput" type="text" /></td>
						<th class="tableleft">传真号码</th>
						<td class="tableright"><input name="merchant.fuxNum" id="fuxNum"  maxlength="32" class="textinput" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">税务登记号</th>
						<td class="tableright"><input name="merchant.taxRegNo" id="taxRegNo"  maxlength="32" class="textinput" type="text" />
						</td>
						<th class="tableleft">发票邮寄地址</th>
						<td class="tableright"><input name="merchant.billAddr" id="billAddr"  maxlength="100" class="textinput" type="text" />
						</td>
						<th class="tableleft">是否月末强制结算</th>
						<td class="tableright"><input name="merchant.isSettleMonth" id="isSettleMonth"  maxlength="100" class="textinput" type="text" />
						</td>
					</tr>
					<tr>
						<th class="tableleft">所属区域</th>
						<td class="tableright"><input name="merchant.region" id="region"  maxlength="100" class="textinput" type="text" />
						</td>
						<td colspan="4"></td>
					</tr>
					<tr>
						<th class="tableleft">备注</th>
						<td class="tableright" colspan ="5">
							<input name="merchant.note" id="note"  maxlength="64" class="textinput easyui-validatebox" type="text" style="width:89%" />
						</td>
					</tr>
				 </table>
			<div>
				<input name="mtype.id" id="id"  type="hidden"/>
				 <table class="tablegrid" style="width: 100%">
				    <tr>
			 	 		<td colspan="6"><h3 class="subtitle">结算参数设置</h3></td>
			 	 	</tr>
				 	<tr>
						<th class="tableleft">结算周期说明:</th>
						<td class="tableright" colspan ="3">
						<span style="color:red">结算方式为日结，结算周期为1表示：每天产生结算数据。<br/>
												结算方式为周结，结算周期为1表示：每周的星期一产生结算数据；结算周期为1|3|5;表示星期一、星期三、星期五产生结算数据。<br/>
												结算方式为月结，结算周期为1表示：每月1号产生结算数据，如果想每月最后一天产生结算数据结算周期写32。</span>
						</td>
					</tr>
					<tr>
					<th class="tableleft">结算模式:</th>
					<td class="tableright"><input name="merchantStlMode.stlMode" id="stlMode"  class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
						<span style="color:red;vertical-align: middle;"> * </span>
					</td>
					<th class="tableleft">生效日期</th>
					<td class="tableright"clospan="3">
						<input name="validDate" id="validDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,minDate:'%y-%M-%d 0:0:0'})" required="required"/>
						<span style="color:red;vertical-align: middle;"> * </span>
					</td>
					<tr>
						<th class="tableleft">消费结算方式</th>
						<td class="tableright"><input name="merchantStlMode.stlWay" id="stlWay"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft" id="styWay1_lmt_th" style="display:none;">限额参数</th>
						<td class="tableright" id="styWay1_lmt_td" style="display:none;"><input name="merchantStlMode.stlLim" id="stlLim"  class="textinput easyui-validatebox" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft" id="styWay1_cicrl_th" style="display:none;">结算周期</th>
						<td class="tableright" id="styWay1_cicrl_td" style="display:none;"><input name="merchantStlMode.stlDays" id="stlDays"  class="textinput easyui-validatebox" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
					</tr>
					<tr>
						<th class="tableleft">退货结算方式</th>
						<td class="tableright"><input name="merchantStlMode.stlWayRet" id="stlWayRet"  class="easyui-combobox easyui-validatebox"  data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft" id="styWay2_lmt_th" style="display:none;">限额参数</th>
						<td class="tableright" id="styWay2_lmt_td" style="display:none;"><input name="merchantStlMode.stlLimRet" id="stlLimRet"  class="textinput easyui-validatebox" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft" id="styWay2_cicrl_th" style="display:none;">结算周期</th>
						<td class="tableright" id="styWay2_cicrl_td" style="display:none;"><input name="merchantStlMode.stlDaysRet" id="stlDaysRet"  class="textinput easyui-validatebox" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
					</tr>
					
					<tr>
						<th class="tableleft">服务费结算方式</th>
						<td class="tableright"><input name="merchantStlMode.stlWayFee" id="stlWayFee"  class="easyui-combobox easyui-validatebox" data-options="panelHeight: 'auto',editable:false" type="text"  style="width:174px;"/>
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft" id="styWay3_lmt_th" style="display:none;">限额参数</th>
						<td class="tableright" id="styWay3_lmt_td" style="display:none;"><input name="merchantStlMode.stlLimFee" id="stlLimFee"  class="textinput easyui-validatebox" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
						<th class="tableleft" id="styWay3_cicrl_th" style="display:none;">结算周期</th>
						<td class="tableright" id="styWay3_cicrl_td" style="display:none;"><input name="merchantStlMode.stlDaysFee" id="stlDaysFee"  class="textinput easyui-validatebox" type="text" />
							<span style="color:red;vertical-align: middle;"> * </span>
						</td>
					</tr>
				 </table>
			</div>
			</form>
	</div>
</div>
