<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%> 
<%@include file="/layout/initpage.jsp" %> 
<script type="text/javascript">
	var $grid;
	var cardinfo;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createLocalDataSelect({id:"servpwdlock",data:[{value:"",text:"未读卡"},{value:"0",text:"正常"},{value:"1",text:"锁定"}]});
		createLocalDataSelect({id:"dealpwdlock",data:[{value:"",text:"未读卡"},{value:"0",text:"正常"},{value:"1",text:"锁定"}]});
		createLocalDataSelect({id:"insuredpwdlock",data:[{value:"",text:"未读卡"},{value:"0",text:"正常"},{value:"1",text:"锁定"}]});
		
		 $.post("pwdservice/pwdserviceAction!getallerrtime.action","",function(result){
			var obj = eval('('+result+')');
			$('#serverrtime2').val(obj.rows[0].PARA_VALUE);
			$('#dealerrtime2').val(obj.rows[1].PARA_VALUE);
		});
	});
	function query(){
		if(dealNull($("#certNo").val()) == "" && dealNull($("#cardNo").val()) == ""){
			$.messager.alert("系统消息","请输入查询证件号码或是卡号！","error");
			return;
		}
		$grid.datagrid("load",{
			queryType:"0",
			certNo:$("#certNo").val(), 
			cardNo:$("#cardNo").val(),
			opType:0
		});
	}

	//读取卡信息
	function readcard(){
		$.messager.progress({text:"正在获取卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		$("#name").val(cardinfo["name"]);
		$("#certNo").val(cardinfo["cert_No"]);

		getdelerrtime();
		getserverrtime();
	}
	//读取客户证件信息
	function readIdCard(){
		$.messager.progress({text:"正在获取卡信息,请稍后..."});
		cardinfo = getcertinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["cert_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error");
			return;
		}
		$("#name").val(cardinfo["name"]);
		$("#certNo").val(cardinfo["cert_No"]);

		getserverrtime();
	}
	//服务密码错误次数查询
	function getserverrtime(){
		 $.post("pwdservice/pwdserviceAction!getserverrtime.action",{"certNo2":$("#certNo").val()},function(result){
				var obj = eval('('+result+')');
				var errtime = obj.rows[0].SERV_PWD_ERR_NUM;
				if (errtime >= 6){
					$('#servpwdlock').combobox('setValue',"1");
					$('#serverrtime').val("0");
				}else {
					$('#servpwdlock').combobox('setValue',"0");
					var allerrtime =$('#serverrtime2').val() - errtime;
					$('#serverrtime').val(allerrtime);
				}
				});
	}
	//交易密码错误查询
	function getdelerrtime(){
		 $.post("pwdservice/pwdserviceAction!getdelerrtime.action",{"cardNo":$("#cardNo").val()},function(result){
				var obj = eval('('+result+')');
				var errtime = obj.rows[0].PAY_PWD_ERR_NUM;
				if (errtime >= 6){
					$('#dealpwdlock').combobox('setValue',"1");
					$('#dealerrtime').val("0");
				}else {
					$('#dealpwdlock').combobox('setValue',"0");
					var allerrtime =$('#dealerrtime2').val() - errtime;
					$('#dealerrtime').val(allerrtime);
				}

				});
	}
	//错误次数重置
	function pwdunlock(type) {
		if (type == "1"){
			if(dealNull($("#servpwdlock").combobox("getValue")) == ""){
				$.messager.alert("系统消息","请先进行读卡操作！","error");
				return;
			}
			if ($("#servpwdlock").combobox("getValue") != "1"){
				$.messager.alert("系统消息","服务密码未锁定！","error");
				return;
			}
			$.post("pwdservice/pwdserviceAction!serverrtimereset.action",{"certNo2":$("#certNo").val()},function(result){
				var obj = eval('('+result+')');
				if (obj.status == "0"){
	     			$.messager.alert('系统消息',obj.msg,"info");
	     			getserverrtime();
				}else {
		     		$.messager.alert('系统消息',obj.errMsg,'error');
				}
			});
		}else if (type == "2"){
			if(dealNull($("#dealpwdlock").combobox("getValue")) == ""){
				$.messager.alert("系统消息","请先进行读卡操作！","error");
				return;
			}
			if ($("#dealpwdlock").combobox("getValue") != "1"){
				$.messager.alert("系统消息","交易密码未锁定！","error");
				return;
			}
			$.post("pwdservice/pwdserviceAction!delerrtimereset.action",{"cardNo":$("#cardNo").val()},function(result){
				var obj = eval('('+result+')');
				if (obj.status == "0"){
	     			$.messager.alert('系统消息',obj.msg,"info");
	     			getdelerrtime();
	     			}else {
		     		$.messager.alert('系统消息',obj.errMsg,'error');
				}
			});
		}else if (type == "3"){
			$.messager.alert('系统消息',3,"error");
		}else {
			$.messager.alert("系统消息","密码解锁类型错误！","error");
		}
		
	}
</script>
<n:initpage title="个人服务密码进行修改操作！服务密码一般用于网站登录或是终端信息查询!">
	<n:center>
		<div style="width:100%;height:auto;border:none;">
			<div id="tb" style="padding:2px 0;background-color:rgb(245,245,245);overflow:hidden;" class="easyui-panel" data-options="border:false,tools:'#toolspanel',fit:true" >
				<input  id="dealerrtime2" type="text" readonly="readonly" hidden="hidden"/>
				<input  id="serverrtime2" type="text" readonly="readonly" hidden="hidden"/>
				<table class="tablegrid">
					<tr>
						<td class="tableleft"  style="width:30%">姓名：</td>
						<td class="tableright" style="width:20%"><input name="name"  class="textinput" id="name" type="text" /></td>
						<td class="tableleft"  style="width:10%">证件号码：</td>
						<td class="tableright" style="width:40%"><input name="certNo"  class="textinput" id="certNo" type="text"  onblur="getserverrtime()"/></td>
					</tr>
					<tr>
						<td class="tableleft"  style="width:30%">卡号：</td>
						<td class="tableright" style="width:20%"><input name="cardNo"  class="textinput" id="cardNo" type="text" onblur="getdelerrtime()"/></td>
						<td class="tableright" style="width:50%" colspan="2">
							<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-readCard'"    onclick="readcard()">读卡</a>
							<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-readIdcard'"  onclick="readIdCard()">读身份证</a>
							<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-search'"      onclick="query()">查询</a>
							<!-- <a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-save'"        onclick="submitForm()">确定</a> -->
						</td>
					</tr>
				</table>
			</div>
		</div>
		
		<!-- 服务密码信息 -->
		<div style="width:100%;height:auto;border:none;">
		  	<div id="tb1" style="padding:2px 0;background-color:rgb(245,245,245);overflow:hidden;" class="easyui-panel" data-options="border:false,tools:'#toolspanel',fit:true" >
				<h3 class="subtitle">服务密码信息</h3>
				<table id="toolpanel" style="width:100%" class="tablegrid">
					<tr>
						<td  class="tableleft" style="width:30%">是否锁定：</td>
						<td  class="tableright" style="width:20%"><input name="servpwdlock" class="textinput easyui-validatebox" id="servpwdlock" type="text" maxlength="20" readonly="readonly"/></td>
						<td  class="tableleft" style="width:10%">密码可输错次数：</td>
						<td  class="tableright" style="width:40%">
							<input name="serverrtime" class="textinput easyui-validatebox" id="serverrtime" type="text" readonly="readonly" />
								<a  data-options="plain:false,iconCls:'icon-unlock'" href="javascript:void(0);" class="easyui-linkbutton" onclick="pwdunlock(1)">解锁</a>
						</td>
					</tr>

				</table>
			</div>
		</div>
		<div></div>
		
		<!-- 交易密码信息 -->
		<div style="width:100%;height:auto;border:none;">
			<div id="tb2" style="padding:2px 0;background-color:rgb(245,245,245);overflow:hidden;" class="easyui-panel" data-options="fit:true,cache:false,border:false,tools:'#toolspanel2'">
				<h3 class="subtitle">交易密码信息</h3>
				<table id="toolpanel2" style="width:100%" class="tablegrid">
					<tr>
						<td  class="tableleft" style="width:30%">是否锁定：</td>
						<td  class="tableright" style="width:20%"><input name="dealpwdlock" class="textinput easyui-validatebox" id="dealpwdlock" type="text" maxlength="20" readonly="readonly"/></td>
						<td  class="tableleft" style="width:10%">密码可输错次数：</td>
						<td  class="tableright" style="width:40%"><input name="dealerrtime" class="textinput easyui-validatebox" id="dealerrtime" type="text" readonly="readonly" />
								<a  data-options="plain:false,iconCls:'icon-unlock'" href="javascript:void(0);" class="easyui-linkbutton" onclick="pwdunlock(2)">解锁</a>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<!-- 医保密码信息-->
		<div style="width:100%;height:auto;border:none;">
			<div id="tb3" style="padding:2px 0;background-color:rgb(245,245,245);overflow:hidden;" class="easyui-panel" data-options="fit:true,cache:false,border:false,tools:'#zzMsg'">
				<h3 class="subtitle">医保密码信息</h3>
				<table id="toolpanel2" style="width:100%" class="tablegrid" id="zzMsg">
					<tr>
						<td  class="tableleft" style="width:30%">是否锁定：</td>
						<td  class="tableright" style="width:20%"><input name="insuredpwdlock" class="textinput easyui-validatebox" id="insuredpwdlock" type="text" maxlength="20" readonly="readonly"/></td>
						<td  class="tableleft" style="width:10%">密码可输错次数：</td>
						<td  class="tableright" style="width:40%">
							<input name="inAccBal" class="textinput easyui-validatebox" id="inAccBal" type="text" readonly="readonly" style="display:inline-block;vertical-align: baseline;"/>
								<a  data-options="plain:false,iconCls:'icon-unlock'" href="javascript:void(0);" class="easyui-linkbutton" onclick="pwdunlock(3)">解锁</a>
								<a class="easyui-linkbutton" href="javascript:void(0);" data-options="plain:false,iconCls:'icon-readCard'"    onclick="readcard2()">读卡</a>
						
						</td>
					</tr>
				</table>
			</div>
		</div>
	</n:center>
</n:initpage>

